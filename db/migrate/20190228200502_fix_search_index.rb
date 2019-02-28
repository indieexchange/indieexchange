class FixSearchIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :posts, name: :search_index
  end
end
