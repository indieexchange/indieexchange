class CreatePostAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :post_attachments do |t|
      t.belongs_to :post, foreign_key: true
      t.text :description
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
