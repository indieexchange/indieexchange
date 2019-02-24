class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # GET /messages/new
  def new
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # GET /messages/1/edit
  def edit
      redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # POST /messages
  # POST /messages.json
  def create
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:sender_id, :recipient_id, :body, :private_message_id)
    end
end
