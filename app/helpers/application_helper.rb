module ApplicationHelper

  def stylesheet_for(controller)
    if controller.starts_with?("devise/") or controller == "registrations"
      return "devise"
    else
      return controller
    end
  end
end
