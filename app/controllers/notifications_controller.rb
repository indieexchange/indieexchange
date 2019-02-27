class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :self_only
  after_action  :update_tracking

  def index
    current_user.update!(has_unread_notifications: false, unread_notification_count: 0)
    @notifications = @user.notifications.order(id: :desc)
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    def update_tracking
      @notifications.update_all(is_unread: false)
    end
end