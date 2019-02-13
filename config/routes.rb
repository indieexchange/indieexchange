Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "static#home"

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_error'

  get "/please_confirm", to: "static#please_confirm", as: "please_confirm"

  get "/users/:id/profile_picture", to: "users#edit_profile_picture", as: "edit_profile_picture_user"
  patch "/users/:id/profile_picture", to: "users#update_profile_picture", as: "update_profile_picture_user"
  patch "/users/:id/delete_profile_picture", to: "users#delete_profile_picture", as: "delete_profile_picture_user"
end
