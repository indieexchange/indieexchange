class AddBasicNotificationPreferencesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email_for_all_notifications, :boolean, null: false, default: true
    add_column :users, :unsubscribe_all_token, :string
  end
end
