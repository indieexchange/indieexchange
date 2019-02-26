class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post,  only:   [:show, :edit, :update, :destroy, :preview, :attachments, :publish,         :unpublish, :bump, :comment, :reply, :comment_replies]
  before_action :set_user,  only:   [:show, :edit, :update, :destroy, :preview, :attachments, :publish,         :unpublish, :bump, :comment, :reply, :comment_replies]
  before_action :set_puser, only:   [                                                                   :posts]
  before_action :self_only, only:   [       :edit, :update, :destroy, :preview, :attachments, :publish,         :unpublish, :bump]
  before_action :hide,      only:   [:show,                                                                                        :comment, :reply]
  before_action :set_comment, only: [                                                                                                        :reply, :comment_replies]

  # GET /posts
  # GET /posts.json
  def index
  end

  def bump
    if @post.bump
      redirect_back(fallback_location: root_path, notice: "Your post has been bumped to the top of its category. You can bump this post again in 72 hours")
    else
      redirect_back(fallback_location: root_path, alert: "Your post could not be bumped. You can try again in #{@post.hours_to_bump} hours")
    end
  end

  def unpublish
    @post.update!(is_published: false)
    redirect_back(fallback_location: root_path, notice: "Your post has been unpublished")
  end

  def comment_replies
    @subcategory = @post.subcategory
    @category = @subcategory.category
    @offering_word = @post.offering_word
    @replies = @comment.post_comment_replies
  end

  def comment
    @comment = PostComment.new(
      body: params["post_comment"]["body"],
      author_id: current_user.id,
      post_id: @post.id,
      target_id: @user.id
      )

    if @comment.save
      redirect_to post_path(@post), notice: "Your comment has been added to this post"
    else
      redirect_to post_path(@post), alert: "Your comment could not be added because it was blank"
    end
  end

  def reply
    @reply = PostCommentReply.new(
      body: params["post_comment_reply"]["body"],
      author_id: current_user.id,
      target_id: @user.id,
      post_id: @post.id,
      post_comment_id: @comment.id
    )

    if params[:direct]
      if @reply.save
        redirect_to post_comment_replies_path(@post, @comment), notice: "Your reply has been added"
      else
        redirect_to post_comment_replies_path(@post, @comment), alert: "Your reply could not be added because it was blank"
      end
    else
      if @reply.save
        redirect_to post_path(@post), notice: "Your reply has been added"
      else
        redirect_to post_path(@post), alert: "Your reply could not be added because it was blank"
      end
    end
  end

  def posts
    if @user == current_user
      @posts = @user.posts
    else
      @posts = @user.posts.visible.published
    end
  end

  def search
    @posts = Post.offering(!ActiveModel::Type::Boolean.new.cast(params[:seeking])).
                  published.
                  visible.
                  subcat(params[:subcategory_id].to_i).
                  max_price(params[:maximum_price].present? ? params[:maximum_price].to_f : nil).
                  keywords(params[:keywords].present? ? params[:keywords].split(" ") : nil).
                  order(:last_update_bump_at)

    @subcategory = Subcategory.find(params[:subcategory_id])

    render :index
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @subcategory = @post.subcategory
    @category = @subcategory.category
    @offering_word = @post.offering_word
    @updated_recently = @post.updated_at > (Time.now - 24.hours)
    @reviews = @post.user_post_reviews.order(id: :desc)
    user_review_count = @user.user_reviews_received.count
    @user_reviews = OpenStruct.new(any?: user_review_count.positive?, count: user_review_count, score: @user.rating)
    @comments = @post.post_comments
    @comment = PostComment.new
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
    @post = Post.new(post_params.merge(user_id: current_user.id, last_update_bump_at: Time.now))

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
      redirect_to post_path(@post), notice: "Your post is now published.  You can view it below"
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

    def set_puser
      @user = User.find(params[:id])
    end

    def set_user
      @user = @post.user
    end

    def set_comment
      @comment = PostComment.find(params[:comment_id])
    end

    def hide
      if @post.hidden? and current_user != @user
        redirect_back(fallback_location: root_path, alert: "Sorry, that post is not available now")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :description, :price, :subcategory_id, :is_offering, :news)
    end
end
