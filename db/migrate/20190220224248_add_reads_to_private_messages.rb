class AddReadsToPrivateMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :private_messages, :unread_a, :boolean, null: false, default: false
    add_column :private_messages, :unread_b, :boolean, null: false, default: false
  end
end
