class CreatePrivateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :private_messages do |t|
      t.belongs_to :user_a, index: true, foreign_key: {to_table: :users}
      t.belongs_to :user_b, index: true, foreign_key: {to_table: :users}
      t.datetime :last_message_time

      t.timestamps
    end
  end
end
