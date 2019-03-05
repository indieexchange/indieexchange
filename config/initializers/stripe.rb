Rails.configuration.stripe = {
  publishable_key: ENV["INDIE_EXCHANGE_STRIPE_PUBLISHABLE_KEY"],
  secret_key:      ENV["INDIE_EXCHANGE_STRIPE_SECRET_KEY"],
  signing_secret:  ENV["INDIE_EXCHANGE_STRIPE_SIGNING_SECRET"]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
