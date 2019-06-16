class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery with: :exception

  before_action :update_params, if: :devise_controller?
  before_action :ensure_membership, unless: :devise_controller?

  after_action :update_last_active
  after_action :update_ip_address_hash

  impersonates :user

  def ensure_membership
    if signed_in? and !current_user.allowed_to_use_site?
      if current_user.is_lapsed?
        redirect_to lapsed_user_path(current_user), notice: "Your membership has lapsed.  Please see below for details" and return
      else
        redirect_to join_user_path(current_user), notice: "Please choose an option for joining Indie Exchange before continuing" and return
      end
    end
  end

  def update_ip_address_hash
    if signed_in?
      # IP Addresses are stored as strings, most recent at [0], least recent at [19].
      # And we're storing *unique* IP addresses, not the last 20 used with duplicates.
      ip_addresses = current_user.ip_address_array
      current_ip = request.ip

      return if current_user.ip_address_array[0] == current_ip

      if ip_addresses.include?(current_ip)
        ip_addresses.delete(current_ip)
      end

      ip_addresses.unshift(current_ip)

      current_user.ip_address_array = ip_addresses[0..19]
      current_user.save!
    end
  end

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

  def admin_only
    unless current_user.is_admin?
      redirect_to root_path, alert: "You don't have permission to take that action" and return
    end
  end

  def self_only
    if current_user != @user
      redirect_to root_path, alert: "You don't have permission to take that action" and return
    end
  end
end
