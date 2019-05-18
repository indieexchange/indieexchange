class ApplicationMailer < ActionMailer::Base
  default from: '"Indie Exchange Support" <support@indiepubexchange.com>'
  layout 'mailer'

  def notify_message_received(user, sender)
    @user = user
    @sender = sender
    mail(to: @user.email, subject: "[Indie Exchange] You got a new message!")
  end

  def subscription_payment_succeeded(user)
    @user = user
    mail(to: @user.email, subject: "[Indie Exchange] Your subscription payment has succeeded")
  end

  def notify_user_membership_expired(user)
    @user = user
    mail(to: @user.email, subject: "[Indie Exchange] Your subscription has been cancelled")
  end

  def charge_upcoming(user, number_of_days)
    @user = user
    @time_remaining = ((number_of_days.days - PADDING_FOR_PAYMENT)/(1.day)).to_i
    mail(to: @user.email, subject: "[Indie Exchange] Your account will be billed in #{@time_remaining} days")
  end

  def please_add_card(user)
    @user = user
    mail(to: @user.email, subject: "[Indie Exchange] Please add a card to continue using Indie Exchange!")
  end
end
