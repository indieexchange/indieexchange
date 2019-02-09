class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery with: :exception

  before_action :update_params, if: :devise_controller?

  def update_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:first_name, :last_name, :email, :password, :password_confirmation, :terms_of_service, :age)
    end
  end

  def after_sign_in_path_for(user)
    user_path(user)
  end
end
