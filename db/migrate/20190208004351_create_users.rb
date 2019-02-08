class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.text :about_me
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :username

      t.timestamps
    end
  end
end
