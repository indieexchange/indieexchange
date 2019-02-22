class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :title,                              null: false
      t.text :description,                          null: false
      t.decimal :price,                             null: false, precision: 12, scale: 2
      t.belongs_to :subcategory, foreign_key: true, null: false
      t.decimal :rating,                            null: false, default: 0
      t.integer :number_of_ratings,                 null: false, default: 0
      t.boolean :is_offering,                       null: false, default: true
      t.boolean :is_promoted,                       null: false, default: false
      t.boolean :is_visible,                        null: false, default: false
      t.datetime :last_update_bump_at,              null: true
      t.belongs_to :user, foreign_key: true,        null: false

      t.timestamps
    end
  end
end
