class AddMessageTrackingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unread_message_count, :integer, null: false, default: 0
    add_column :users, :has_unread_messages, :boolean, null: false, default: false
  end
end
