class RegistrationsController < Devise::RegistrationsController
  private

  def after_inactive_sign_up_path_for(user)
    please_confirm_path
  end
end