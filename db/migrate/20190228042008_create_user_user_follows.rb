class CreateUserUserFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :user_user_follows do |t|
      t.belongs_to :follower, foreign_key: { to_table: :users }, index: true
      t.belongs_to :target,   foreign_key: { to_table: :users }, index: true

      t.timestamps
    end
  end
end
