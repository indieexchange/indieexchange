class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :dashboard,
                                  :edit_profile_picture, :update_profile_picture, :delete_profile_picture,
                                  :crop_profile_picture, :post_reviews]
  before_action :self_only, only: [      :edit, :update, :destroy, :dashboard,
                                   :edit_profile_picture, :update_profile_picture, :delete_profile_picture,
                                   :crop_profile_picture, :post_reviews]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  def post_reviews
    @reviews = @user.post_reviews_written.order(id: :desc)
  end

  # GET /users/1
  # GET /users/1.json
  def show
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
        :profile_picture, :crop_x, :crop_y, :crop_w, :crop_h)
    end
end
