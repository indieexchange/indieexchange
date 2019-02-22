class StaticController < ApplicationController
  def home
    if signed_in?
      redirect_to dashboard_user_path
    end
  end

  def please_confirm
  end
end
