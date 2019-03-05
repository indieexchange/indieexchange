class AddTrialPeriodColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_trial_period, :boolean, null: false, default: false
    add_column :users, :trial_until, :datetime
    rename_column :users, :stripe_payment_method_token, :stripe_card_id
    add_column :users, :stripe_card_brand, :string
    add_column :users, :stripe_card_last_four, :string
  end
end
