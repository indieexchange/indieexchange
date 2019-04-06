#  TODO:  When trial period is over, make this more efficient ("must_pay_next_at" should be way easier/faster)

namespace :users do
  desc "Handle membership closure for people who are done their trial / subscription"
  task handle_payments_daily: :environment do
    now = Time.now
    # (created_at < now - 15.days) ensures that brand new accounts never get annoyed by this
    User.all.where("created_at < ?", now - 15.days).find_each do |user|
      time = user.must_pay_next_at

      # the process here is:
      # run this task ONCE PER DAY
      # if your payment is ~7 days away, just send a reminder that the payment is coming
      # if your payment is ~3 days away, just send a reminder that the payment is coming
      # if your payment is <2 days away AND you don't have a card, ask them to add a card. because this runs
      # daily, a user could get this particular message two times in the days before payment is due.
      # if your payment is <2 days away but you do have a card, just ignore it -- they've already gotten two
      # emails saying that the payment is coming.

      if now > (time - 7.days) and now < (time - 6.days)
        ApplicationMailer.charge_upcoming(user, 7).deliver_now
      elsif now > (time - 4.days) and now < (time - 3.days)
        ApplicationMailer.charge_upcoming(user, 4).deliver_now
      elsif now > (time - 2.days) and now < time
        if user.stripe_card_id.blank?
          ApplicationMailer.please_add_card(user).deliver_now
        end
      end
    end
  end

  task handle_payments_quarter_hourly: :environment do
    now = Time.now
    # (created_at < now - 15.days) ensures that brand new accounts never get annoyed by this
    User.all.where("created_at < ?", now - 15.days).find_each do |user|
      time = user.must_pay_next_at

      # the process here is
      # run this task EVERY FIFTEEN MINUTES
      # if it's PAST time to charge you and you do have a card, charge you and keep you current.  (perfect timing!)
      # if it's PAST time to charge you and you don't have a card, suspend your account for non-payment.
      # if it's within the padding-time to charge you (so, your payment is due within like 48 hours),
      # then we TRY to charge you, but we don't punish you or anything if we fail.

      if now > time
        if user.stripe_card_id.present? # one last chance, if they just added a card?
          begin
            PaymentService.charge_month_and_record_for(user)
          rescue StandardError => e
            puts "Error occurred attempting overdue payment for User ID = #{user.id} (#{user.email})."
            puts "OVERDUE PAYMENT ERROR MESSAGE:"
            puts e.message
            puts "Continuing with other users."
          end
        else
          user.suspend_account_for_payment
        end
      elsif now > (time - PADDING_FOR_PAYMENT)
        if user.stripe_card_id.present?
          begin
            PaymentService.charge_month_and_record_for(user)
          rescue StandardError => e
            puts "Error occurred attempting padding-due payment for User ID = #{user.id} (#{user.email})."
            puts "PADDING_DUE PAYMENT ERROR MESSAGE:"
            puts e.message
            puts "Continuing with other users. No notification needed."
          end
        end
      end
    end
  end
end