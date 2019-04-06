class StaticController < ApplicationController
  def home
    if signed_in?
      redirect_to dashboard_user_path
    end
  end

  def please_confirm
  end

  def privacy_policy
  end

  def rules
  end

  def contact
  end

  def terms
  end
end
