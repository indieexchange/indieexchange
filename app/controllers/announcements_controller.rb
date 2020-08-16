class AnnouncementsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only,       only: [:new, :edit, :update, :destroy, :create]
  before_action :set_announcement, only: [:show, :edit, :update, :destroy, :reply, :destroy_reply]

  # GET /announcements
  # GET /announcements.json
  def index
    current_user.update!(has_unread_announcement: false)
    @announcements = Announcement.all.order(id: :desc)
  end

  # GET /announcements/1
  # GET /announcements/1.json
  def show
    @announcement_reply = AnnouncementReply.new
    if @announcement == Announcement.first
      current_user.update!(has_unread_first_announcement: false, has_unread_announcement: false)
    end
  end

  def destroy_reply
    reply = AnnouncementReply.find(params[:reply_id])
    if reply.user == current_user
      reply.destroy!
      redirect_to announcement_path(@announcement), notice: "Your reply has been deleted"
    else
      redirect_to announcement_path(@announcement), alert: "You can only delete your own replies"
    end
  end

  def reply
    body = params[:announcement_reply][:body]
    if body.present?
      AnnouncementReply.create!(user: current_user, body: body, announcement: @announcement)
      redirect_to announcement_path(@announcement), notice: "Your reply has been added"
    else
      redirect_to announcement_path(@announcement), alert: "Replies can not be empty"
    end
  end

  # GET /announcements/new
  def new
    @announcement = Announcement.new
  end

  # GET /announcements/1/edit
  def edit
  end

  # POST /announcements
  # POST /announcements.json
  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user = current_user

    if @announcement.save
      redirect_to @announcement, notice: 'Announcement was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /announcements/1
  # PATCH/PUT /announcements/1.json
  def update
    if @announcement.update(announcement_params)
      redirect_to @announcement, notice: 'Announcement was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.json
  def destroy
    @announcement.destroy
    redirect_to announcements_url, notice: 'Announcement was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def admin_only
      unless current_user&.is_admin?
        redirect_to root_path, alert: "You don't have permission to take that action" and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def announcement_params
      params.require(:announcement).permit(:body, :title)
    end
end
