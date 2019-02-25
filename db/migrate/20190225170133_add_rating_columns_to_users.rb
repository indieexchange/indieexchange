class AddRatingColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :number_of_ratings, :integer, null: false, default: 0
    add_column :users, :rating, :decimal, null: false, default: 0
  end
end
