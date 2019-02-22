json.extract! private_message, :id, :user_a_id, :user_b_id, :post_id, :last_message_time, :created_at, :updated_at
json.url private_message_url(private_message, format: :json)
