class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.decimal :amount,          null: false
      t.string :card_brand,       null: false
      t.string :card_last_four,   null: false
      t.boolean :succeeded,       null: false
      t.string :stripe_charge_id, null: false
      t.belongs_to :user,         foreign_key: true, index: true

      t.timestamps
    end
  end
end
