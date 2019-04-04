class CreateAnnouncementReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :announcement_replies do |t|
      t.belongs_to :announcement, foreign_key: true
      t.belongs_to :user,         foreign_key: true
      t.text :body,               null: false

      t.timestamps
    end
  end
end
