class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.text :body, null: false
      # t.text :title, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
