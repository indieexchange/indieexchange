namespace :users do
  desc "Handle membership closure for people who are done their trial / subscription"
  task handle_payments_daily: :environment do
    User.all.where("created_at < ?", Time.now - 15.days).find_each do |user|
      now = Time.now
      time = user.must_pay_next_at
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
    User.all.where("created_at < ?", Time.now - 15.days).find_each do |user|
      now = Time.now
      time = user.must_pay_next_at
      if now > time
        if user.stripe_card_id.present? # one last chance, if they just added a card?
          PaymentService.charge_month_and_record_for(user)
        else
          user.suspend_account_for_payment
        end
      elsif now > (time - PADDING_FOR_PAYMENT)
        if user.stripe_card_id.present?
          PaymentService.charge_month_and_record_for(user)
        end
      end
    end
  end
end