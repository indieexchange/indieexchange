class CreatePostComments < ActiveRecord::Migration[5.2]
  def change
    create_table :post_comments do |t|
      t.belongs_to :author, foreign_key: {to_table: :users}, index: true
      t.belongs_to :target, foreign_key: {to_table: :users}, index: true
      t.belongs_to :post,   foreign_key: {to_table: :posts}, index: true
      t.text :body,         null: false

      t.timestamps
    end
  end
end
