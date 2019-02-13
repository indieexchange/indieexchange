module ApplicationHelper

  def on_profile_page(path, id)
    path == "/users/#{id}/profile_picture" or path == "/users/#{id}/edit" ? true : false
  end

  def stylesheet_for(controller)
    if controller.starts_with?("devise/") or controller == "registrations"
      return "devise"
    else
      return controller
    end
  end
end
