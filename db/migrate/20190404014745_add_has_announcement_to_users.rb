class AddHasAnnouncementToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :has_unread_announcement, :boolean, default: false, null: false
    add_column :users, :has_unread_first_announcement, :boolean, default: true, null: false
    add_column :users, :is_admin, :boolean, default: false, null: false
  end
end
