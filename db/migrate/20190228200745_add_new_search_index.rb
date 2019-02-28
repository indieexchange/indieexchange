class AddNewSearchIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :posts, [:is_published, :is_visible, :category_id,
                       :subcategory_id, :is_offering, :price, :last_update_bump_at],
                       name: :new_search_index
  end
end
