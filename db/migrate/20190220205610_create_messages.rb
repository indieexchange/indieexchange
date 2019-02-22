class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.belongs_to :sender, foreign_key: {to_table: :users}, index: true
      t.belongs_to :recipient, foreign_key: {to_table: :users}, index: true
      t.text :body, null: false
      t.belongs_to :private_message, foreign_key: true, index: true

      t.timestamps
    end
  end
end
