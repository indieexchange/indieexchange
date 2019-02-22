class PrivateMessage < ApplicationRecord
  belongs_to :user_a, class_name: "User"
  belongs_to :user_b, class_name: "User"

  has_many :messages, dependent: :destroy

  def other_user(user)
    user == user_a ? user_b : user_a
  end

  def unread_by(user)
    (user == user_a and unread_a) or (user == user_b and unread_b)
  end
end
