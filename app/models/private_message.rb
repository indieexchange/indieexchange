class PrivateMessage < ApplicationRecord
  # note: for consistency, user_a should ALWAYS have the lower id than user_b
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

  def self.between(u1, u2)
    # reminder: user_a should have a lower id value than user_b
    user_a, user_b = u1.id < u2.id ? [u1, u2] : [u2, u1]
    PrivateMessage.where(user_a: user_a, user_b: user_b).first
  end

  def allows_review?
    # allow a review as long as there's been at least one back-and-forth between the two
    messages.where(sender: user_a).any? and messages.where(sender: user_b).any?
  end

  def update_read_tracking_for(reader)
    if reader == user_a and unread_a
      update!(unread_a: false)
      reader.reduce_unread_count
    elsif reader == user_b and unread_b
      update!(unread_b: false)
      reader.reduce_unread_count
    end
  end

  def handle_new_message(sent_by, received_by, current_user_a)
    received_by.handle_new_message_in(self)
    update_on_send_from(sent_by, received_by, current_user_a)
  end

  def read_by(user)
    !unread_by(user)
  end

  def update_on_send_from(sent_by, received_by, current_user_a)
    if sent_by == current_user_a
      update!(unread_a: false, unread_b: true, last_message_time: Time.now)
    else
      update!(unread_a: true, unread_b: false, last_message_time: Time.now)
    end
  end

  def last_message
    messages.last
  end

  def last_message_body_to(n)
    last_message.body.truncate(n)
  end
end
