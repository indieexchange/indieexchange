class SetUnsubscribeAllTokens < ActiveRecord::Migration[5.2]
  def change
    User.all.each do |user|
      user.unsubscribe_all_token = SecureRandom.base58(80)
      user.save!
    end
  end
end
