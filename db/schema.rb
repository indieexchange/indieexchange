# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_14_025758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "announcement_replies", force: :cascade do |t|
    t.bigint "announcement_id"
    t.bigint "user_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_replies_on_announcement_id"
    t.index ["user_id"], name: "index_announcement_replies_on_user_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.text "body", null: false
    t.text "title", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "title", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "recipient_id"
    t.text "body", null: false
    t.bigint "private_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["private_message_id"], name: "index_messages_on_private_message_id"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "is_unread", default: true, null: false
    t.text "body", null: false
    t.string "link", null: false
    t.integer "triggered_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", null: false
    t.string "card_brand", null: false
    t.string "card_last_four", null: false
    t.boolean "succeeded", null: false
    t.string "stripe_charge_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "post_attachments", force: :cascade do |t|
    t.bigint "post_id"
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_post_attachments_on_post_id"
    t.index ["user_id"], name: "index_post_attachments_on_user_id"
  end

  create_table "post_comment_replies", force: :cascade do |t|
    t.bigint "post_id"
    t.bigint "author_id"
    t.bigint "target_id"
    t.bigint "post_comment_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_post_comment_replies_on_author_id"
    t.index ["post_comment_id"], name: "index_post_comment_replies_on_post_comment_id"
    t.index ["post_id"], name: "index_post_comment_replies_on_post_id"
    t.index ["target_id"], name: "index_post_comment_replies_on_target_id"
  end

  create_table "post_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "target_id"
    t.bigint "post_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_post_comments_on_author_id"
    t.index ["post_id"], name: "index_post_comments_on_post_id"
    t.index ["target_id"], name: "index_post_comments_on_target_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "price", precision: 12, scale: 4, null: false
    t.bigint "subcategory_id", null: false
    t.decimal "rating", default: "0.0", null: false
    t.integer "number_of_ratings", default: 0, null: false
    t.boolean "is_offering", default: true, null: false
    t.boolean "is_promoted", default: false, null: false
    t.boolean "is_visible", default: true, null: false
    t.datetime "last_update_bump_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "news"
    t.boolean "is_published", default: false, null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["is_published", "is_visible", "category_id", "subcategory_id", "is_offering", "price", "last_update_bump_at"], name: "new_search_index"
    t.index ["subcategory_id"], name: "index_posts_on_subcategory_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "private_messages", force: :cascade do |t|
    t.bigint "user_a_id"
    t.bigint "user_b_id"
    t.datetime "last_message_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "unread_a", default: false, null: false
    t.boolean "unread_b", default: false, null: false
    t.index ["user_a_id"], name: "index_private_messages_on_user_a_id"
    t.index ["user_b_id"], name: "index_private_messages_on_user_b_id"
  end

  create_table "subcategories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.string "pricing_type", default: "word", null: false
    t.index ["category_id"], name: "index_subcategories_on_category_id"
  end

  create_table "user_post_reviews", force: :cascade do |t|
    t.bigint "reviewing_user_id"
    t.bigint "target_user_id"
    t.bigint "post_id"
    t.string "title", null: false
    t.text "body", null: false
    t.integer "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_anonymous", default: false, null: false
    t.index ["post_id"], name: "index_user_post_reviews_on_post_id"
    t.index ["reviewing_user_id"], name: "index_user_post_reviews_on_reviewing_user_id"
    t.index ["target_user_id"], name: "index_user_post_reviews_on_target_user_id"
  end

  create_table "user_user_follows", force: :cascade do |t|
    t.bigint "follower_id"
    t.bigint "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id"], name: "index_user_user_follows_on_follower_id"
    t.index ["target_id"], name: "index_user_user_follows_on_target_id"
  end

  create_table "user_user_reviews", force: :cascade do |t|
    t.bigint "reviewing_user_id"
    t.bigint "target_user_id"
    t.string "title", null: false
    t.text "body", null: false
    t.integer "score", null: false
    t.boolean "is_anonymous", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewing_user_id"], name: "index_user_user_reviews_on_reviewing_user_id"
    t.index ["target_user_id"], name: "index_user_user_reviews_on_target_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "about_me"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "profile_picture_x"
    t.integer "profile_picture_y"
    t.integer "profile_picture_d"
    t.datetime "last_active"
    t.integer "unread_message_count", default: 0, null: false
    t.boolean "has_unread_messages", default: false, null: false
    t.integer "number_of_ratings", default: 0, null: false
    t.decimal "rating", default: "0.0", null: false
    t.boolean "has_unread_notifications", default: false, null: false
    t.integer "unread_notification_count", default: 0, null: false
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.boolean "is_verified", default: false, null: false
    t.datetime "verified_until"
    t.string "stripe_customer_id"
    t.string "stripe_card_id"
    t.boolean "is_trial_period", default: false, null: false
    t.datetime "trial_until"
    t.string "stripe_card_brand"
    t.string "stripe_card_last_four"
    t.boolean "is_lapsed", default: false, null: false
    t.boolean "has_unread_announcement", default: false, null: false
    t.boolean "has_unread_first_announcement", default: true, null: false
    t.boolean "is_admin", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcement_replies", "announcements"
  add_foreign_key "announcement_replies", "users"
  add_foreign_key "announcements", "users"
  add_foreign_key "messages", "private_messages"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "post_attachments", "posts"
  add_foreign_key "post_attachments", "users"
  add_foreign_key "post_comment_replies", "post_comments"
  add_foreign_key "post_comment_replies", "posts"
  add_foreign_key "post_comment_replies", "users", column: "author_id"
  add_foreign_key "post_comment_replies", "users", column: "target_id"
  add_foreign_key "post_comments", "posts"
  add_foreign_key "post_comments", "users", column: "author_id"
  add_foreign_key "post_comments", "users", column: "target_id"
  add_foreign_key "posts", "categories"
  add_foreign_key "posts", "subcategories"
  add_foreign_key "posts", "users"
  add_foreign_key "private_messages", "users", column: "user_a_id"
  add_foreign_key "private_messages", "users", column: "user_b_id"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "user_post_reviews", "posts"
  add_foreign_key "user_post_reviews", "users", column: "reviewing_user_id"
  add_foreign_key "user_post_reviews", "users", column: "target_user_id"
  add_foreign_key "user_user_follows", "users", column: "follower_id"
  add_foreign_key "user_user_follows", "users", column: "target_id"
  add_foreign_key "user_user_reviews", "users", column: "reviewing_user_id"
  add_foreign_key "user_user_reviews", "users", column: "target_user_id"
end
