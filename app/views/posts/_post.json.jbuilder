json.extract! post, :id, :title, :description, :price, :subcategory_id, :rating, :is_offering, :is_promoted, :is_visible, :last_update_bump_at, :created_at, :updated_at
json.url post_url(post, format: :json)
