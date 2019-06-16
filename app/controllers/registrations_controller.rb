class RegistrationsController < Devise::RegistrationsController
  private

  def after_inactive_sign_up_path_for(user)
    please_confirm_path
  end

  def after_update_path_for(resource)
    edit_user_path(current_user)
  end
end