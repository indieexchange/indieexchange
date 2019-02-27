class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.belongs_to :user,         foreign_key: true, index: true
      t.boolean    :is_unread,    null: false,       default: true
      t.text       :body,         null: false
      t.string     :link,         null: false
      t.integer    :triggered_by, null: false

      t.timestamps
    end
  end
end
