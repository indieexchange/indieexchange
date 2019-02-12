class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable, :lockable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates_acceptance_of :terms_of_service, message: "must be accepted"
  validates_acceptance_of :age,              message: "must be over 18"

  validates :username, format: { with: /\A[a-zA-Z]{1}[a-zA-Z0-9 ]{0,22}[a-zA-Z0-9]{1}\Z|\A\Z/,
                                 message: "must start with a letter, not use punctuation, not end with a space, and be under 24 characters",
                                 allow_nil: true }

  validate :username_not_unset

  def username_not_unset
    if username.present? and will_save_change_to_username?
      errors.add(:username, "can't be changed or deleted after being set")
    end
  end

  def display_name
    value = username.present? ? username : [first_name, last_name].join(" ")
    value.truncate(24)
  end

  def profile_incomplete?
    about_me.blank? # or profile_picture.blank?
  end
end
