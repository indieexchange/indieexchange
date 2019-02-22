class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post,  only: [:show, :edit, :update, :destroy, :preview, :attachments, :publish]
  before_action :set_user,  only: [:show, :edit, :update, :destroy, :preview, :attachments, :publish]
  before_action :self_only, only: [       :edit, :update, :destroy, :preview, :attachments, :publish]

  # GET /posts
  # GET /posts.json
  def index
  end

  def search
    @posts = Post.offering(!ActiveModel::Type::Boolean.new.cast(params[:seeking])).
                  subcat(params[:subcategory_id].to_i).
                  max_price(params[:maximum_price].present? ? params[:maximum_price].to_f : nil).
                  keywords(params[:keywords].present? ? params[:keywords].split(" ") : nil).
                  order(:id)

    @subcategory = Subcategory.find(params[:subcategory_id])

    render :index
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params.merge(user_id: current_user.id))

    if @post.save
      if params[:save_and_add_attachments].present?
        redirect_to attachments_post_path(@post), notice: "Your post has been saved. You may manage its attachments below"
      else # then we want to go directly to preview
        redirect_to preview_post_path(@post), notice: "Your post has been saved. Please check the preview below"
      end
    else
      render :new
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    if @post.update(post_params)
      if params[:save_and_add_attachments].present?
        redirect_to attachments_post_path(@post), notice: "Your post has been saved. You may manage its attachments below"
      else # then we want to go directly to preview
        redirect_to preview_post_path(@post), notice: "Your post has been saved. Please check the preview below"
      end
    else
      render :edit
    end
  end

  def publish
    if @post.is_published?
      redirect_to post_path(@post), alert: "This post is already published"
    elsif @post.update(is_published: true)
      redirect_to post_path(@post), notice: "Congratulations! Your post is now published.  You can view it below"
    else
      redirect_to preview_post_path(@post), alert: "Sorry, your post is not able to be published at this time"
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    def set_user
      @user = @post.user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :description, :price, :subcategory_id, :is_offering, :news)
    end
end
