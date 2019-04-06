class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable, :trackable, :lockable,
         :recoverable, :rememberable, :validatable, :confirmable

  devise :two_factor_authenticatable, otp_secret_encryption_key: ENV["INDIE_EXCHANGE_ENCRYPTION_KEY"]

  validates_acceptance_of :terms_of_service, message: "must be accepted"
  validates_acceptance_of :age,              message: "must be over 18"

  validates :username, format: { with: /\A[a-zA-Z]{1}[a-zA-Z0-9 ]{0,22}[a-zA-Z0-9]{1}\Z|\A\Z/,
                                 message: "must start with a letter, not use punctuation, not end with a space, and be under 24 characters",
                                 allow_nil: true }

  validate :username_not_unset
  validate :profile_picture_file_size_acceptable, if: :validate_profile_picture_change
  validate :profile_picture_file_type_acceptable, if: :validate_profile_picture_change
  validate :username_unique, if: :will_save_change_to_username?

  has_one_attached :profile_picture
  has_many :posts, dependent: :destroy
  has_many :post_attachments # *DON'T* use d:d because posts will destroy them anyway
  has_many :private_messages_a, class_name: "PrivateMessage", foreign_key: "user_a_id", dependent: :destroy
  has_many :private_messages_b, class_name: "PrivateMessage", foreign_key: "user_b_id", dependent: :destroy

  has_many :post_reviews_written, class_name: "UserPostReview", foreign_key: "reviewing_user_id", dependent: :destroy
  has_many :post_reviews_received, class_name: "UserPostReview", foreign_key: "target_user_id", dependent: :destroy

  has_many :user_reviews_written, class_name: "UserUserReview", foreign_key: "reviewing_user_id", dependent: :destroy
  has_many :user_reviews_received, class_name: "UserUserReview", foreign_key: "target_user_id", dependent: :destroy

  has_many :post_comments_written, class_name: "PostComment", foreign_key: "author_id"
  has_many :post_comments_received, class_name: "PostComment", foreign_key: "target_id"

  has_many :post_comment_replies_written, class_name: "PostCommentReply", foreign_key: "author_id"
  has_many :post_comment_replies_received, class_name: "PostCommentReply", foreign_key: "target_id"

  has_many :following_others, class_name: "UserUserFollow", foreign_key: "follower_id"
  has_many :followed_by_others, class_name: "UserUserFollow", foreign_key: "target_id"

  has_many :followers, through: :followed_by_others, source: :follower
  has_many :followeds, through: :following_others, source: :target

  has_many :notifications, dependent: :destroy

  has_many :payments, dependent: :destroy

  has_many :announcements, dependent: :destroy
  has_many :announcement_replies, dependent: :destroy

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :validate_profile_picture_change, :promo_code
  before_save :crop_profile_picture

  before_save :check_has_unread_messages, if: :will_save_change_to_unread_message_count?

  after_create :count_creation_as_activity

  def count_creation_as_activity
    update!(last_active: Time.now)
  end

  def allowed_to_use_site?
    (is_verified and verified_until > Time.now) or (is_trial_period and trial_until > Time.now)
  end

  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_id) if stripe_customer_id.present?
  end

  def stripe_card
    stripe_customer.sources.retrieve(stripe_card_id) if stripe_card_id.present?
  end

  def must_pay_immediately?
    (!is_verified) and (!is_trial_period)
  end

  def must_pay_next_at
    # TODO: When trial period is all done, make this way more efficient =) and check for usages elsewhere!
    [verified_until || Time.now, trial_until || Time.now].max
  end

  def delete_card
    if stripe_customer_id.present? and stripe_card_id.present?
      Stripe::Customer.delete_source(stripe_customer_id, stripe_card_id)
      update!(stripe_card_id: nil, stripe_card_brand: nil, stripe_card_last_four: nil)
    end
  end

  def can_add_trial?
    is_verified == false and is_trial_period == false
  end

  def suspend_account_for_payment
    stripe_customer&.sources&.map(&:delete)
    update!(is_verified: false, is_trial_period: false, is_lapsed: true,
            stripe_card_id: nil, stripe_card_brand: nil, stripe_card_last_four: nil)
    posts.map{ |post| post.update!(is_visible: false) }
    ApplicationMailer.notify_user_membership_expired(self).deliver_now
  end

  def unsuspend_account_after_payment
    posts.map{ |post| post.update!(is_visible: true) }
  end

  def qrcode_link
    update!(otp_secret: User.generate_otp_secret) unless otp_secret.present?
    issuer = "Indie Exchange"
    label = "#{issuer}:#{email}"
    otp_provisioning_uri(label, issuer: issuer)
  end

  def clear_2fa_information!
    update!(otp_required_for_login: false,
            otp_secret: nil,
            encrypted_otp_secret: nil,
            encrypted_otp_secret_iv: nil,
            encrypted_otp_secret_salt: nil,
            consumed_timestep: nil)
  end

  def is_following?(target)
    UserUserFollow.where(follower: self, target: target).any?
  end

  def can_review?(post)
    PrivateMessage.between(self, post.user)&.allows_review? and post.allows_review?(self)
  end

  def can_review_user?(target_user)
    PrivateMessage.between(self, target_user)&.allows_review? and target_user.allows_review?(self)
  end

  def allows_review?(reviewing_user)
    user_reviews_received.where(reviewing_user: reviewing_user).blank?
  end

  def private_messages
    private_messages_a.or(private_messages_b)
  end

  def check_has_unread_messages
    self.has_unread_messages = unread_message_count > 0
  end

  def unread_message_count_display
    [unread_message_count, 99].min
  end

  def unread_notification_count_display
    [unread_notification_count, 99].min
  end

  def reduce_unread_count
    update!(unread_message_count: unread_message_count - 1)
  end

  def handle_new_message_in(private_message)
    # if someone already messaged you once and it's unread, don't increase the unread thread count again
    update!(unread_message_count: unread_message_count + 1) if private_message.read_by(self)
  end

  def self.profile_picture_maximum_size
    "450x450" # best to pick a highly divisible number
  end

  def self.profile_picture_thumbnail_size
    "90x90" # divided by 8
  end

  def username_unique
    if username.present? and User.where(username: username).any?
      errors.add(:username, "is already taken")
    end
  end

  def username_not_unset
    if username_was.present? and will_save_change_to_username?
      errors.add(:username, "can't be changed or deleted after being set")
    end
  end

  def profile_picture_file_size_acceptable
    if profile_picture.attached?
      if profile_picture.blob.byte_size > 4 * 1000 * 1000 # 4 megabytes (BYTE, not BIT)
        profile_picture.purge
        errors.add(:profile_picture, "is over the maximum allowed size of 4MB. Please choose a smaller file.")
      end
    end
  end

  def profile_picture_file_type_acceptable
    if profile_picture.attached? and !profile_picture.content_type.in?(["image/x-png", "image/png", "image/jpeg", "image/bmp"])
      profile_picture.purge
      errors.add(:profile_picture, "must be a PNG, JPG, or BMP file")
    end
  end

  def display_name
    value = username.present? ? username : [first_name, last_name].join(" ")
    value.truncate(24)
  end

  def display_name_untruncated
    value = username.present? ? username : [first_name, last_name].join(" ")
  end

  def profile_incomplete?
    about_me.blank? or !profile_picture.attached? or profile_picture_d.nil?
  end

  def last_n_posts(n)
    posts.last(n).reverse
  end

  def last_n_private_messages(n)
    private_messages.hydrated.order(last_message_time: :desc).last(n)
  end

  def last_n_post_reviews(n)
    post_reviews_written.order(id: :desc).last(n)
  end

  def last_n_user_reviews(n)
    user_reviews_written.order(id: :desc).last(n)
  end

  def complete_profile_call_to_action
    if about_me.blank? and !profile_picture.attached?
      cta = "Your profile is incomplete. For best results on Indie Exchange, please" +
      " #{link_to 'update your bio', edit_user_path(self)} and" +
      " add a #{link_to 'profile picture', edit_profile_picture_user_path(self)}"
    elsif about_me.blank?
      cta = "Your profile is incomplete. For best results on Indie Exchange, please" +
      " #{link_to 'update your bio', edit_user_path(self)}"
    elsif !profile_picture.attached?
      cta = "Your profile is incomplete. For best results on Indie Exchange, please" +
      " add a #{link_to 'profile picture', edit_profile_picture_user_path(self)}"
    elsif profile_picture_d.nil?
      cta = "Your profile is incomplete. For best results on Indie Exchange, please" +
      " #{link_to "crop your profile picture", crop_profile_picture_user_path(self)}"
      cta.html_safe
    end
    cta.html_safe
  end

  def has_cropped_profile_picture?
    profile_picture_d.present? and profile_picture.attached?
  end

  def crop_profile_picture
    if crop_x.present?
      self.profile_picture_x = crop_x
      self.profile_picture_y = crop_y
      self.profile_picture_d = crop_h # since it's always square, the [d]imensions have height == width
    end
  end

  def pp_full
    profile_picture.variant(
      resize: User.profile_picture_maximum_size,
      crop: "#{profile_picture_d}x#{profile_picture_d}+#{profile_picture_x}+#{profile_picture_y}"
    ).processed
  end

  def pp_mid
    divisor = 1.0 * profile_picture_d / 240
    profile_picture.variant(
      resize: "#{(450/divisor).to_i}x#{(450/divisor).to_i}",
      crop: "#{(profile_picture_d/divisor).to_i}x#{(profile_picture_d/divisor).to_i}+" +
            "#{(profile_picture_x/divisor).to_i}+#{(profile_picture_y/divisor).to_i}"
    ).processed
  end

  def pp_thumb
    divisor = 1.0 * profile_picture_d / 60
    profile_picture.variant(
      resize: "#{(450/divisor).to_i}x#{(450/divisor).to_i}",
      crop: "#{(profile_picture_d/divisor).to_i}x#{(profile_picture_d/divisor).to_i}+" +
            "#{(profile_picture_x/divisor).to_i}+#{(profile_picture_y/divisor).to_i}"
    ).processed
  end
end
