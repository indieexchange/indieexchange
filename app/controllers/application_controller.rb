class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery with: :exception

  before_action :update_params, if: :devise_controller?

  after_action :update_last_active

  def update_last_active
    if signed_in?
      current_user.update_columns(last_active: Time.now)
    end
  end

  def update_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:first_name, :last_name, :email, :password, :password_confirmation, :terms_of_service, :age)
    end
  end

  def after_sign_in_path_for(user)
    root_path
  end

  private

  def self_only
    if current_user != @user
      redirect_to root_path, alert: "You don't have permission to take that action" and return
    end
  end
end
