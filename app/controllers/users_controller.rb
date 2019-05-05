class UsersController < ApplicationController
  skip_before_action :ensure_membership, only: [:join, :begin_trial, :wait_for_stripe, :check_stripe, :lapsed]
  before_action :redirect_lapsed,        only: [:join, :begin_trial, :wait_for_stripe, :check_stripe         ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :dashboard,
                                   :edit_profile_picture, :update_profile_picture, :delete_profile_picture,
                                   :crop_profile_picture, :post_reviews, :user_reviews, :clear_notifications,
                                   :tfa, :activate_tfa, :deactivate_tfa, :follow, :unfollow, :payment, :join,
                                   :wait_for_stripe, :check_stripe, :delete_card, :cancel_subscription,
                                   :resubscribe, :lapsed, :follows]
  before_action :self_only, only: [      :edit, :update, :destroy, :dashboard,
                                   :edit_profile_picture, :update_profile_picture, :delete_profile_picture,
                                   :crop_profile_picture, :post_reviews, :user_reviews, :clear_notifications,
                                   :tfa, :activate_tfa, :deactivate_tfa, :follow, :unfollow, :payment, :join,
                                   :wait_for_stripe, :check_stripe, :delete_card, :cancel_subscription,
                                   :resubscribe, :lapsed, :follows]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  def follows
    @followers = @user.followed_by_others.includes(:follower).order(created_at: :desc)
    @followeds = @user.following_others.includes(:target).order(created_at: :desc)
  end

  def join
  end

  def lapsed
  end

  def wait_for_stripe
  end

  def check_stripe
    render json: { is_verified: @user.is_verified }
  end

  def resubscribe
    @user.resubscribe
    redirect_to payment_user_path(@user), notice: "Thanks! Your membership has been activated."
  end

  def cancel_subscription
    @user.cancel_subscription
    redirect_to payment_user_path(@user), notice: "Your subscription has been cancelled"
  end

  def delete_card
    @user.delete_card
    redirect_to payment_user_path(current_user), notice: "Your card has been removed"
  end

  def begin_trial
    if !current_user.can_add_trial?
      redirect_back(fallback_location: root_path, alert: "Sorry, your account isn't eligible for a free trial")
    elsif params[:user][:promo_code] == "indie-exchange-45-free" or params[:user][:promo_code] == "indie-exchange-90-free"
      current_user.update!(is_trial_period: true, trial_until: Time.now + 90.days)
      redirect_to root_path, notice: "Thanks! Your 90-day free trial has begun"
    else
      redirect_back(fallback_location: root_path, alert: "Oops! That coupon code didn't work")
    end
  end

  def clear_notifications
    @user.notifications.destroy_all
    @user.update!(unread_notification_count: 0, has_unread_notifications: false)
    redirect_to user_path(@user), notice: "Your notifications have been cleared"
  end

  def post_reviews
    @reviews = @user.post_reviews_written.order(id: :desc)
  end

  def user_reviews
    @reviews = @user.user_reviews_written.order(id: :desc)
  end

  def payment
    @payments = @user.payments.order(id: :desc)
  end

  def follow
    target = User.find(params[:target_id])
    uuf = UserUserFollow.new(target: target, follower: current_user)
    if uuf.save
      render json: { success: true }, status: 200
    else
      render json: { success: false, error: uuf.errors.full_messages.first }, status: 403
    end
  end

  def unfollow
    target = User.find(params[:target_id])
    uuf = UserUserFollow.where(target: target, follower: current_user).first&.destroy!
    render json: { success: true }, status: 200
  end

  def tfa
    @qrcode_link = @user.qrcode_link
    @already_enabled = @user.otp_required_for_login
  end

  def deactivate_tfa
    if params[:user][:otp_attempt].gsub(" ", "") == @user.current_otp
      @user.clear_2fa_information!
      redirect_to user_path(@user), notice: "Two-factor authentication for your account has been disabled"
    else
      redirect_back(fallback_location: root_path, alert: "Incorrect code: deactivation could not be completed")
    end
  end

  def activate_tfa
    if params[:user][:otp_attempt].gsub(" ", "") == @user.current_otp
      @user.update!(otp_required_for_login: true)
      redirect_to user_path(@user), notice: "Two-factor authentication has been enabled for your account"
    else
      redirect_back(fallback_location: root_path, alert: "Sorry, your confirmation failed. Try deleting and re-scanning the QR code")
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @reviews = @user.user_reviews_received.order(id: :desc)
    @is_following = current_user.is_following?(@user)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def dashboard
    @posts = @user.last_n_posts(2)
    @private_messages = @user.last_n_private_messages(3)
    @post_reviews = @user.last_n_post_reviews(3)
    @user_reviews = @user.last_n_user_reviews(3)
  end

  # POST /users
  # POST /users.json
  def create
    redirect_back(fallback_location: root_path, alert: "You don't have permission to take that action") and return
    # @user = User.new(user_params)

    # respond_to do |format|
    #   if @user.save
    #     format.html { redirect_to @user, notice: 'User was successfully created.' }
    #     format.json { render :show, status: :created, location: @user }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @user.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Your changes have been saved' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_profile_picture
  end

  def crop_profile_picture
    render :crop
  end

  def update_profile_picture
    @user.validate_profile_picture_change = true
    if @user.update(user_params)
      render :crop
    else
      render :edit_profile_picture
    end
  end

  def delete_profile_picture
    @user.profile_picture.purge
    @user.update!(profile_picture_x: nil, profile_picture_y: nil, profile_picture_d: nil)
    redirect_to edit_profile_picture_user_path(@user), notice: "Your profile picture has been removed"
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def redirect_lapsed
      if current_user.is_lapsed?
        redirect_to lapsed_user_path(current_user), alert: "Please reactivate your membership below"
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id]) if params[:id]
      if @user.nil? and params[:action] == "dashboard"
        @user = current_user
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:about_me, :first_name, :last_name, :username,
        :profile_picture, :crop_x, :crop_y, :crop_w, :crop_h, :otp_attempt)
    end
end
