class PrivateMessage < ApplicationRecord
  belongs_to :user_a, class_name: "User"
  belongs_to :user_b, class_name: "User"

  has_many :messages, dependent: :destroy

  scope :hydrated, -> { joins(:messages).group('private_messages.id') }

  def other_user(user)
    user == user_a ? user_b : user_a
  end

  def unread_by(user)
    (user == user_a and unread_a) or (user == user_b and unread_b)
  end

  def last_message
    messages.last
  end

  def last_message_body_to(n)
    last_message.body.truncate(n)
  end
end
