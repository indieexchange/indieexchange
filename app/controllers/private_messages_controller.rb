class PrivateMessagesController < ApplicationController
  # before_action :set_private_message, only: [:show, :edit, :update, :destroy]
  before_action :set_instance_variables_from_users,           only: [:show, :edit, :update, :destroy, :start]
  before_action :set_instance_variables_from_private_message, only: [:new_message]
  before_action :set_user,                                    only: [:index]
  before_action :self_only,                                   only: [:index]

  # GET /private_messages
  # GET /private_messages.json
  def index
    @private_messages = @user.private_messages.hydrated.order(last_message_time: :desc)
  end

  # GET /private_messages/1
  # GET /private_messages/1.json
  def show
    @message = Message.new
  end

  def start
    @message = Message.new
    @private_message.update_read_tracking_for(current_user)
    render :show
  end

  def new_message
    @message = Message.new(message_params.merge(
                           sender: current_user,
                           recipient: @other_user,
                           private_message: @private_message))
    if @message.save
      @private_message.handle_new_message(current_user, @other_user, @user_a)
      redirect_back(fallback_location: root_path, notice: "Your message has been sent")
    else
      render :show, alert: "Your message could not be sent"
    end
  end

  # GET /private_messages/new
  def new
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # GET /private_messages/1/edit
  def edit
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # POST /private_messages
  # POST /private_messages.json
  def create
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # PATCH/PUT /private_messages/1
  # PATCH/PUT /private_messages/1.json
  def update
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  # DELETE /private_messages/1
  # DELETE /private_messages/1.json
  def destroy
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_private_message
      @private_message = PrivateMessage.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_instance_variables_from_private_message
      @private_message = PrivateMessage.includes(:messages).find(params[:id])
      @messages = @private_message.messages.order(:id)
      @user_a = @private_message.user_a
      @user_b = @private_message.user_b

      if @user_a != current_user and @user_b != current_user
        redirect_back(fallback_location: root_path,
                      alert: "You don't have permission to take that action") and return
      end

      @other_user = @private_message.other_user(current_user)
    end

    def set_instance_variables_from_users
      if params[:id_a].blank? or params[:id_b].blank?
        redirect_back(fallback_location: root_path,
                      alert: "Could not perform messaging between the specified users") and return
      end

      ids = [params[:id_a], params[:id_b]].map(&:to_i)

      @user_a = User.where(id: ids.min).first
      @user_b = User.where(id: ids.max).first

      if @user_a.nil? or @user_b.nil?
        redirect_back(fallback_location: root_path,
                      alert: "Could not find both of the specified users") and return
      end

      if @user_a != current_user and @user_b != current_user
        redirect_back(fallback_location: root_path,
                      alert: "You don't have permission to take that action") and return
      end

      @private_message = PrivateMessage.includes(:messages).where(user_a: @user_a, user_b: @user_b).first

      if @private_message.nil?
        @private_message = PrivateMessage.create!(user_a: @user_a, user_b: @user_b)
      else
        @messages = @private_message.messages.order(:id)
      end

      @other_user = @private_message.other_user(current_user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_message_params
      params.require(:private_message).permit(:user_a_id, :user_b_id)
    end

    def message_params
      params.require(:message).permit(:body)
    end
end
