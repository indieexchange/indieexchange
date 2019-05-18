class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :private_message

  after_create :notify_recipient_by_email

  def notify_recipient_by_email
    if recipient.email_for_all_notifications
      ApplicationMailer.notify_message_received(recipient, sender).deliver_now
    end
  end
end
