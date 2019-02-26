class CreatePostCommentReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :post_comment_replies do |t|
      t.belongs_to :post,         foreign_key: true
      t.belongs_to :author,       foreign_key: { to_table: :users }
      t.belongs_to :target,       foreign_key: { to_table: :users }
      t.belongs_to :post_comment, foreign_key: true
      t.text       :body,         null:        false

      t.timestamps
    end
  end
end
