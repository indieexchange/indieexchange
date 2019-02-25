class AddIsAnonymousToUserPostReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :user_post_reviews, :is_anonymous, :boolean, null: false, default: false
  end
end
