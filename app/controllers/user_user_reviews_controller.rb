class UserUserReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_instance_variables, only: [:new, :create                         ]
  before_action :check_review_allowed,   only: [:new, :create                         ]
  before_action :set_from_id,            only: [               :show, :destroy        ]
  before_action :one_per_combination,    only: [:new, :create                         ]
  before_action :reviewer_only,          only: [                      :destroy        ]
  before_action :set_target,             only: [                                :index]

  def new
    @user_user_review = UserUserReview.new
  end

  def index
    @reviews = @target.user_reviews_received.order(id: :desc)
  end

  def show
  end

  def destroy
    @user_user_review.destroy
    redirect_to user_path(@target), notice: "Your review for this user has been permanently deleted"
  end

  def create
    @user_user_review = UserUserReview.new(user_user_review_params.merge({
      reviewing_user_id: current_user.id,
      target_user_id: @target.id,
    }))

    if @user_user_review.save
      redirect_to user_path(@target), notice: "Thank you! Your review has been added to this user"
    else
      render :new
    end
  end

  private

    def set_target
      @target = User.find(params[:user_id])
    end

    def user_user_review_params
      params.require(:user_user_review).permit(:title, :body, :score, :is_anonymous)
    end

    def set_instance_variables
      @target = User.find(params[:user_id])
      @reviewer = current_user
    end

    def set_from_id
      @user_user_review = UserUserReview.find(params[:id])
      @reviewer = @user_user_review.reviewing_user
      @target = @user_user_review.target_user
    end

    def reviewer_only
      if current_user != @reviewer
        redirect_back(fallback_location: root_path, alert: "You don't have permission to delete this post") and return
      end
    end

    def check_review_allowed
      unless @reviewer.can_review_user?(@target)
        redirect_back(fallback_location: root_path, alert: "You can't review this post yet. Please check our FAQ for details") and return
      end
    end

    def one_per_combination
      if UserUserReview.where(reviewing_user: @reviewer, target_user: @target).any?
        redirect_back(fallback_location: root_path, alert: "You have already reviewed this post") and return
      end
    end
end