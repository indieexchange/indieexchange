class AddPaymentColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_verified, :boolean, null: false, default: false
    add_column :users, :verified_until, :datetime
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_payment_method_token, :string
  end
end
