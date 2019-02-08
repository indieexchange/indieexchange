Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "static#home"

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_error'

  get "/please_confirm", to: "static#please_confirm", as: "please_confirm"
end
