class AddCoordinateColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.integer :profile_picture_x, null: true
      t.integer :profile_picture_y, null: true
      t.integer :profile_picture_d, null: true
    end
  end
end
