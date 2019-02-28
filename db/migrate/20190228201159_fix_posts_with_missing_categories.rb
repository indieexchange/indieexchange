class FixPostsWithMissingCategories < ActiveRecord::Migration[5.2]
  def change
    Post.all.each do |post|
      post.update_columns(category_id: post.subcategory.category_id)
    end
  end
end
