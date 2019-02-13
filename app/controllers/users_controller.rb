class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy,
                                  :edit_profile_picture, :update_profile_picture, :delete_profile_picture]
  before_action :self_only, only: [:show, :edit, :update, :destroy,
                                   :edit_profile_picture, :update_profile_picture, :delete_profile_picture]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
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

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_profile_picture
  end

  def update_profile_picture
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
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:about_me, :first_name, :last_name, :username,
        :profile_picture, :crop_x, :crop_y, :crop_w, :crop_h)
    end
end
