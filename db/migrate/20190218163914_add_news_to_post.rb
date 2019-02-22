class AddNewsToPost < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :news, :text
    add_column :posts, :is_published, :boolean, null: false, default: false
  end
end
