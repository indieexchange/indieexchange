class Post < ApplicationRecord
  belongs_to :subcategory
  belongs_to :category
  belongs_to :user

  has_many   :post_attachments, dependent: :destroy
  has_many   :user_post_reviews, dependent: :destroy

  validates :title,       presence: true, length: { maximum: 128 }
  validates :description, presence: true, length: { maximum: 8192 }
  validates :news,                        length: { maximum: 4096 }
  validates :price,       presence: true, numericality: { greater_than: 0, less_than: 1_000_000 }

  scope :offering,  proc{ |offering_status| where(is_offering: offering_status) unless offering_status.nil? }
  scope :cat,       proc{ |category_id|     where(category_id: category_id) unless category_id.nil? }
  scope :subcat,    proc{ |subcategory_id|  where(subcategory_id: subcategory_id) unless subcategory_id.nil? }
  scope :max_price, proc{ |max_price|       where("price <= ?", max_price) unless max_price.nil? }
  scope :keywords,  proc{ |words|           where(words.map{ |w| "(title ILIKE ? OR description ILIKE ?)" }.
                                            join(" AND "),
                                            *words.collect{ |w| ["%#{w}%", "%#{w}%"] }.flatten) unless words.nil? }

  scope :published, -> { where(is_published: true) }
  scope :visible,   -> { where(is_visible: true) }

  has_many :post_comments, dependent: :destroy
  has_many :post_comment_replies

  after_save :notify_followers_of_visibility
  after_save :notify_followers_of_update_news, if: :saved_change_to_news?
  after_save :notify_follower_of_nonvisibility
  before_destroy :notify_followers_of_destroy

  before_validation :set_category, if: :will_save_change_to_subcategory_id?

  def set_category
    self.category = self.subcategory.category
  end

  def notify_followers_of_visibility
    if (saved_change_to_is_visible? or saved_change_to_is_published?) and is_visible? and is_published?
      user.followers.each do |follower|
        Notification.configure!(:followed_post_visibility, follower, {post: self})
      end
    end
  end

  def notify_followers_of_update_news
    unless hidden?
      user.followers.each do |follower|
        Notification.configure!(:followed_updates_post_news, follower, {post: self})
      end
    end
  end

  def notify_follower_of_nonvisibility
    if (!is_visible_was) or (!is_published_was)
      if (saved_change_to_is_visible? and !is_visible) or (saved_change_to_is_published? and !is_published?)
        user.followers.each do |follower|
          Notification.configure!(:followed_post_nonvisibility, follower, {post: self})
        end
      end
    end
  end

  def notify_followers_of_destroy
    unless hidden?
      user.followers.each do |follower|
        Notification.configure!(:followed_destroys_post, follower, {post: self})
      end
    end
  end

  def self.seeking_options
    [["Services offered by others", "job-offerers"],["People who need my services", "job-seekers"],["Everything", "both"]]
  end

  def self.booleans_for_offering_vs_seeking(word)
    case word
    when "job-offerers"
      true
    when "job-seekers"
      false
    when "both"
      nil
    end
  end

  def self.display_price_string(price)
    decimal_places = [price.to_f.to_s.split(".")[1].length, 2].max
    "%.#{decimal_places}f" % price
  end

  def display_price_string
    Post.display_price_string(price)
  end

  def self.description_for_offering_vs_seeking(word)
    case word
    when "job-offerers"
      "Offers"
    when "job-seekers"
      "Seekers"
    when "both"
      "Offers & Seekers"
    when nil
      "Offers & Seekers"
    end
  end

  def hidden?
    (!is_published) or (!is_visible)
  end

  def offering_word
    is_offering ? "Offering" : "Seeking"
  end

  def bump
    if is_bumpable?
      update!(last_update_bump_at: Time.now)
    else
      return false
    end
  end

  def allows_review?(reviewer)
    user_post_reviews.where(reviewing_user: reviewer).blank?
  end

  def is_bumpable?
    last_update_bump_at.nil? or (last_update_bump_at < (Time.now - 72.hours))
  end

  def hours_to_bump
    (((last_update_bump_at + 72.hours) - Time.now)/(1.hour)).round
  end
end