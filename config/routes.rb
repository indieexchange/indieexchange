Rails.application.routes.draw do
  resources :posts do
    resources :user_post_reviews
    resources :post_attachments
    resources :post_comments
  end
  devise_for :users, controllers: { registrations: "registrations" }

  resources :users do
    resources :user_user_reviews
    resources :notifications, only: [:index]
    resources :private_messages do
      resources :messages
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "static#home"

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_error'

  get "/please_confirm",                              to: "static#please_confirm",          as: "please_confirm"

  get "/users/:id/profile_picture",                   to: "users#edit_profile_picture",     as: "edit_profile_picture_user"
  patch "/users/:id/profile_picture",                 to: "users#update_profile_picture",   as: "update_profile_picture_user"
  patch "/users/:id/delete_profile_picture",          to: "users#delete_profile_picture",   as: "delete_profile_picture_user"
  get "/users/:id/crop_profile_picture",              to: "users#crop_profile_picture",     as: "crop_profile_picture_user"
  get "/dashboard",                                   to: "users#dashboard",                as: "dashboard_user"

  get "/posts/:id/attachments",                       to: "posts#attachments",              as: "attachments_post"
  get "/posts/:id/preview",                           to: "posts#preview",                  as: "preview_post"
  patch "/posts/:id/publish",                         to: "posts#publish",                  as: "publish_post"
  post "/posts/search",                               to: "posts#search",                   as: "search_posts"
  get "/users/:id/posts",                             to: "posts#posts",                    as: "user_posts"
  patch "/posts/:id/unpublish",                       to: "posts#unpublish",                as: "unpublish_post"
  patch "/posts/:id/bump",                            to: "posts#bump",                     as: "bump_post"

  patch "/posts/:post_id/post_attachments/:id/purge", to: "post_attachments#purge",         as: "purge_post_post_attachment"

  get "/private_messages/:id_a/with/:id_b",           to: "private_messages#start",         as: "start_private_message"
  post "/private_messages/:id/new_message",           to: "private_messages#new_message",   as: "new_message_private_message"

  get "/user/:id/post_reviews",                       to: "users#post_reviews",             as: "post_reviews_user"
  get "/user/:id/user_reviews",                       to: "users#user_reviews",             as: "user_reviews_user"

  put "/post/:id/comment",                            to: "posts#comment",                  as: "post_comment"
  put "/post/:id/comment/:comment_id",                to: "posts#reply",                    as: "post_reply"
  get "/post/:id/comment/:comment_id",                to: "posts#comment_replies",          as: "post_comment_replies"
  get "/users/:id/clear_notifications",               to: "users#clear_notifications",      as: "clear_notifications"
end
