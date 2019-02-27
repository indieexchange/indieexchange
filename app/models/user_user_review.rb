class UserUserReview < ApplicationRecord
  belongs_to :reviewing_user, class_name: "User"
  belongs_to :target_user, class_name: "User"

  validates :body, presence: true
  validates :title, presence: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  after_create :update_target_information
  before_destroy :update_target_information_for_destruction

  after_create :notify_target_user

  def notify_target_user
    Notification.configure!(:user_review_received, target_user, {user_user_review: self})
  end

  def update_target_information
    target_user.number_of_ratings += 1

    if target_user.number_of_ratings == 1
      target_user.rating = score
    else
      existing_points = (target_user.number_of_ratings - 1) * target_user.rating
      total_points = existing_points + score
      new_rating = ((1.0 * total_points) / (target_user.number_of_ratings)).round(2) # out to two decimal places
      target_user.rating = new_rating
    end

    target_user.save(touch: false)
  end

  def update_target_information_for_destruction
    target_user.number_of_ratings -= 1

    if target_user.number_of_ratings == 0
      target_user.rating = 0
    else
      existing_points = (target_user.number_of_ratings + 1) * target_user.rating
      total_points = existing_points - score
      new_rating = ((1.0 * total_points) / (target_user.number_of_ratings)).round(2) # out to two decimal places
      target_user.rating = new_rating
    end

    target_user.save(touch: false)
  end
end