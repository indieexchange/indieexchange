class PaymentService
  def self.destroy_all_customers
    User.where.not(stripe_customer_id: nil).each do |stripe_user|
      Stripe::Customer.retrieve(stripe_user.stripe_customer_id).delete
    end

    User.update_all(verified_until: nil, is_verified: false,
      stripe_customer_id: nil, stripe_card_id: nil
      )
  end

  def self.unverify_all_users
    User.where.not(stripe_customer_id: nil).each do |stripe_user|
      Stripe::Customer.retrieve(stripe_user.stripe_customer_id).delete
    end

    User.update_all(verified_until: nil, is_verified: false,
      stripe_customer_id: nil, stripe_card_id: nil,
      is_trial_period: false, trial_until: nil
      )
  end

  def self.set_card_information_for(user, token)
    card                       = Stripe::Customer.create_source(user.stripe_customer_id, {source: token})
    user.stripe_card_brand     = card.brand
    user.stripe_card_last_four = card.last4
    user.stripe_card_id        = card.id
    user.save!
    true
  end

  def self.charge_month_and_record_for(user, send_email = true)
    card = user.stripe_card
    charge = Stripe::Charge.create(
        :customer        => user.stripe_customer_id,
        :amount          => 1000,
        :description     => "Indie Exchange - Monthly Membership",
        :currency        => 'usd',
        :receipt_email   => user.email,
        :source          => card.id
      )

    user.is_verified    = true
    user.verified_until = user.must_pay_next_at + 1.month
    user.is_lapsed      = false
    user.save!

    payment                  = Payment.new
    payment.stripe_charge_id = charge.id
    payment.amount           = 10.00
    payment.card_brand       = card.brand
    payment.card_last_four   = card.last4
    payment.succeeded        = true
    payment.user             = user
    payment.save!

    ApplicationMailer.subscription_payment_succeeded(user).deliver_now
    true
  end
end