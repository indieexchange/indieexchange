class AddSearchIndexesForPosts < ActiveRecord::Migration[5.2]
  def change
    add_index :posts, [:is_published, :is_visible, :subcategory_id, :is_offering, :price, :last_update_bump_at], name: "search_index"
  end
end
