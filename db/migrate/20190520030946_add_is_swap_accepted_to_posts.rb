class AddIsSwapAcceptedToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :is_swap_accepted, :boolean, null: false, default: false
  end
end
