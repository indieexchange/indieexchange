class AddNotificationTrackingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :has_unread_notifications, :boolean, null: false, default: false
    add_column :users, :unread_notification_count, :integer, null: false, default: 0
  end
end
