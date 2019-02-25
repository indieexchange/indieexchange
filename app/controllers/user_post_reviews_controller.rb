class UserPostReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_instance_variables, only: [:new, :create                         ]
  before_action :check_review_allowed,   only: [:new, :create                         ]
  before_action :set_from_id,            only: [               :show, :destroy        ]
  before_action :one_per_combination,    only: [:new, :create                         ]
  before_action :reviewer_only,          only: [                      :destroy        ]
  before_action :set_post,               only: [                                :index]

  def new
    @user_post_review = UserPostReview.new
  end

  def index
    @reviews = @post.user_post_reviews.order(id: :desc)
  end

  def show
  end

  def destroy
    @user_post_review.destroy
    redirect_to post_path(@post), notice: "Your review for this post has been permanently deleted"
  end

  def create
    @user_post_review = UserPostReview.new(user_post_review_params.merge({
      reviewing_user_id: current_user.id,
      target_user_id: @target.id,
      post_id: @post.id
    }))

    if @user_post_review.save
      redirect_to @post, notice: "Thank you! Your review has been added to this post"
    else
      render :new
    end
  end

  private

    def set_post
      @post = Post.find(params[:post_id])
    end

    def user_post_review_params
      params.require(:user_post_review).permit(:title, :body, :score, :is_anonymous)
    end

    def set_instance_variables
      @post = Post.find(params[:post_id])
      @reviewer = current_user
      @target   = @post.user
    end

    def set_from_id
      @user_post_review = UserPostReview.find(params[:id])
      @post = @user_post_review.post
      @reviewer = @user_post_review.reviewing_user
      @target = @user_post_review.target_user
    end

    def reviewer_only
      if current_user != @reviewer
        redirect_back(fallback_location: root_path, alert: "You don't have permission to delete this post") and return
      end
    end

    def check_review_allowed
      unless @reviewer.can_review?(@post)
        redirect_back(fallback_location: root_path, alert: "You can't review this post yet. Please check our FAQ for details") and return
      end
    end

    def one_per_combination
      if UserPostReview.where(reviewing_user: @reviewer, post: @post).any?
        redirect_back(fallback_location: root_path, alert: "You have already reviewed this post") and return
      end
    end
end