class PostAttachmentsController < ApplicationController
  before_action :set_post
  before_action :set_post_attachment,  only: [:show, :edit, :update, :destroy, :purge]
  before_action :models_align
  before_action :set_user,             only: [:show, :edit, :update, :destroy, :purge]
  before_action :self_only,            only: [       :edit, :update, :destroy, :purge]

  # GET /post_attachments
  # GET /post_attachments.json
  def index
    redirect_to root_path, alert: "This action is not allowed"
  end

  # GET /post_attachments/1
  # GET /post_attachments/1.json
  def show
    redirect_to root_path, alert: "This action is not allowed"
  end

  # GET /post_attachments/new
  def new
    @post_attachment = PostAttachment.new
  end

  # GET /post_attachments/1/edit
  def edit
  end

  # POST /post_attachments
  # POST /post_attachments.json
  def create
    @post_attachment = PostAttachment.new(post_attachment_params.merge(user_id: current_user.id, post_id: @post.id))

    if @post_attachment.save
      redirect_to attachments_post_path(@post), notice: "Your attachment was added"
    else
      render :new
    end
  end

  # PATCH/PUT /post_attachments/1
  # PATCH/PUT /post_attachments/1.json
  def update
      if @post_attachment.update(post_attachment_params)
        redirect_to attachments_post_path(@post), notice: 'Your attachment was updated'
      else
        render :edit
      end
  end

  # DELETE /post_attachments/1
  # DELETE /post_attachments/1.json
  def destroy
    @post_attachment.destroy
    redirect_to attachments_post_path(@post), notice: 'Attachment successfully removed'
  end

  def purge
    if @post_attachment.document.attached?
      @post_attachment.document.purge
      redirect_to edit_post_post_attachment_path(@post, @post_attachment), notice: 'Document has been removed'
    else
      redirect_to edit_post_post_attachment_path(@post, @post_attachment), alert: 'No document available to be removed'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def models_align
      if @post and @post_attachment and @post_attachment.post != @post
        redirect_to root_path, alert: "You don't have permission to take that action" and return
      end

      if @post.user != current_user
        redirect_to root_path, alert: "You don't have permission to take that action" and return
      end
    end

    def set_post_attachment
      @post_attachment = PostAttachment.find(params[:id])
    end

    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_user
      @user = @post_attachment.user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_attachment_params
      params.require(:post_attachment).permit(:description, :document)
    end
end
