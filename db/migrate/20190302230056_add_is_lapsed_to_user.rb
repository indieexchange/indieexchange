class AddIsLapsedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_lapsed, :boolean, null: false, default: false
  end
end
