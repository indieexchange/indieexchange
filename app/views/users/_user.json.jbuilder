json.extract! user, :id, :about_me, :first_name, :last_name, :username, :created_at, :updated_at
json.url user_url(user, format: :json)
