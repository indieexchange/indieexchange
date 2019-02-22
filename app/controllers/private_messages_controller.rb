class PrivateMessagesController < ApplicationController
  # before_action :set_private_message, only: [:show, :edit, :update, :destroy]
  before_action :set_instance_variables_from_users,           only: [:show, :edit, :update, :destroy, :start]
  before_action :set_instance_variables_from_private_message, only: [:new_message]
  before_action :set_user,                                    only: [:index]
  before_action :self_only,                                   only: [:index]

  # GET /private_messages
  # GET /private_messages.json
  def index
    @private_messages = @user.private_messages.order(last_message_time: :desc)
  end

  # GET /private_messages/1
  # GET /private_messages/1.json
  def show
    @message = Message.new
  end

  def start
    @message = Message.new
    update_tracking_for(current_user)
    render :show
  end

  def new_message
    @message = Message.new(message_params.merge(
                           sender: current_user,
                           recipient: @other_user,
                           private_message: @private_message))
    if @message.save
      @other_user.unread_message_count += 1
      @other_user.save

      update_thread(current_user, @other_user)

      redirect_back(fallback_location: root_path, notice: "Your message has been sent")
    else
      render :show
    end
  end

  # GET /private_messages/new
  def new
    @private_message = PrivateMessage.new
  end

  # GET /private_messages/1/edit
  def edit
  end

  # POST /private_messages
  # POST /private_messages.json
  def create
    @private_message = PrivateMessage.new(private_message_params)

    respond_to do |format|
      if @private_message.save
        format.html { redirect_to @private_message, notice: 'Private message was successfully created.' }
        format.json { render :show, status: :created, location: @private_message }
      else
        format.html { render :new }
        format.json { render json: @private_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /private_messages/1
  # PATCH/PUT /private_messages/1.json
  def update
    respond_to do |format|
      if @private_message.update(private_message_params)
        format.html { redirect_to @private_message, notice: 'Private message was successfully updated.' }
        format.json { render :show, status: :ok, location: @private_message }
      else
        format.html { render :edit }
        format.json { render json: @private_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /private_messages/1
  # DELETE /private_messages/1.json
  def destroy
    @private_message.destroy
    respond_to do |format|
      format.html { redirect_to private_messages_url, notice: 'Private message was successfully destroyed.' }
      format.json { head :no_content }
    end
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

    def update_thread(sender, recipient)
      if sender == @user_a
        @private_message.update!(unread_a: false, unread_b: true, last_message_time: Time.now)
      else
        @private_message.update!(unread_a: true, unread_b: false, last_message_time: Time.now)
      end
    end

    def update_tracking_for(reader)
      if reader == @private_message.user_a and @private_message.unread_a
        @private_message.update!(unread_a: false)
        reader.update!(unread_message_count: reader.unread_message_count - 1)
      elsif reader == @private_message.user_b and @private_message.unread_b
        @private_message.update!(unread_b: false)
        reader.update!(unread_message_count: reader.unread_message_count - 1)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def private_message_params
      params.require(:private_message).permit(:user_a_id, :user_b_id)
    end

    def message_params
      params.require(:message).permit(:body)
    end
end
