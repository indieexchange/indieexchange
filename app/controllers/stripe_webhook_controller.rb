class StripeWebhookController < ApplicationController
  before_action :send_back_in_staging
  before_action :authenticate_user!,             only: [:subscribe, :add_card]
  before_action :set_customer,                   only: [:subscribe, :add_card]
  skip_before_action :verify_authenticity_token, only: [:stripe]
  skip_before_action :ensure_membership

  def add_card
    PaymentService.set_card_information_for(current_user, params[:stripeToken])
    redirect_to payment_user_path(current_user), notice: "Success! Your card has been added"
  end

  def subscribe
    PaymentService.set_card_information_for(current_user, params[:stripeToken])
    PaymentService.charge_month_and_record_for(current_user)

    redirect_to payment_user_path(current_user), notice: "Thanks! Your subscription is now active"
  rescue StandardError => e
    10.times{ puts e.message.colorize(:red) }
    redirect_back(fallback_location: root_path, alert: "We were unable to begin your subscription.  Please try again or contact us.")
  end

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    event = nil

    begin
        event = Stripe::Webhook.construct_event(payload, sig_header, Rails.configuration.stripe[:signing_secret])
    rescue JSON::ParserError => e
        # Invalid payload
        status 400
        return
    rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        status 400
        return
    end

    render plain: "OK"
  end

  private

    def send_back_in_staging
      redirect_back(fallback_location: root_path, alert: "Sorry! This feature is disabled here.")
    end

    def set_customer
      if current_user.stripe_customer_id.blank?
        @customer = Stripe::Customer.create(
          email: params[:stripeEmail]
        )
        current_user.stripe_customer_id = @customer.id
        current_user.save!
      else
        @customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      end
    end
end