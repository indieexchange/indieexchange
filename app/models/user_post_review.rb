class UserPostReview < ApplicationRecord
  belongs_to :reviewing_user, class_name: "User"
  belongs_to :target_user, class_name: "User"
  belongs_to :post

  validates :body, presence: true
  validates :title, presence: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  after_create :update_post_information
  after_create :notify_post_author
  before_destroy :update_post_information_for_destruction

  def notify_post_author
    Notification.configure!(:post_review_received, target_user, {user_post_review: self})
  end

  def update_post_information
    post.number_of_ratings += 1

    if post.number_of_ratings == 1
      post.rating = score
    else
      existing_points = (post.number_of_ratings - 1) * post.rating
      total_points = existing_points + score
      new_rating = ((1.0 * total_points) / (post.number_of_ratings)).round(2) # out to two decimal places
      post.rating = new_rating
    end

    post.save(touch: false)
  end

  def update_post_information_for_destruction
    post.number_of_ratings -= 1

    if post.number_of_ratings == 0
      post.rating = 0
    else
      existing_points = (post.number_of_ratings + 1) * post.rating
      total_points = existing_points - score
      new_rating = ((1.0 * total_points) / (post.number_of_ratings)).round(2) # out to two decimal places
      post.rating = new_rating
    end

    post.save(touch: false)
  end
end