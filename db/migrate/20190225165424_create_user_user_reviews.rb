class CreateUserUserReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :user_user_reviews do |t|
      t.belongs_to :reviewing_user, foreign_key: {to_table: :users}, index: true
      t.belongs_to :target_user,    foreign_key: {to_table: :users}, index: true
      t.string     :title,                                                        null: false
      t.text       :body,                                                         null: false
      t.integer    :score,                                                        null: false
      t.boolean    :is_anonymous,                                                 null: false, default: false

      t.timestamps
    end
  end
end
