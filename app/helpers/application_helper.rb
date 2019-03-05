module ApplicationHelper

  def block_profile_completeness_method(path, id)
    path == "/users/#{id}/profile_picture" or
    path == "/users/#{id}/crop_profile_picture" or
    path == "/users/#{id}/edit" or
    path == "/users/#{id}/join" or
    path == "/users/#{id}/lapsed" or
    path == "/users/#{id}/wait_for_stripe" ? true : false
  end

  def stylesheet_for(controller)
    if controller.starts_with?("devise/") or controller == "registrations"
      return "devise"
    else
      return controller
    end
  end
end
