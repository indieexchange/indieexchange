class Notification < ApplicationRecord
  @@routes = Rails.application.routes.url_helpers
  belongs_to :user

  enum triggered_by: { post_commented_on:       0,
                       post_comment_replied_to: 1,
                       post_review_received:    2,
                       user_review_received:    3
                      }

  after_create :update_user_tracking

  def update_user_tracking
    user.update!(has_unread_notifications: true, unread_notification_count: user.unread_notification_count + 1)
  end

  def self.configure!(notification_type, target, options)
    if notification_type == :post_commented_on
      notification = Notification.configure_post_commented_on(target, options)
    elsif notification_type == :post_comment_replied_to
      notification = Notification.configure_post_comment_replied_to(target, options)
    elsif notification_type == :post_review_received
      notification = Notification.configure_post_review_received(target, options)
    elsif notification_type == :user_review_received
      notification = Notification.configure_user_review_received(target, options)
    end

    notification.save!
  end

  def self.configure_user_review_received(target, options)
    user_user_review = options[:user_user_review]
    author = user_user_review.reviewing_user

    if user_user_review.is_anonymous?
      body_text = "An anonymous user added a review to your profile"
    else
      body_text = "#{author.display_name_untruncated} added a review to your profile"
    end

    notification = Notification.new(
        user: target,
        body: body_text,
        link: @@routes.user_user_user_review_path(author, user_user_review),
        triggered_by: :post_review_received
      )
  end

  def self.configure_post_review_received(target, options)
    user_post_review = options[:user_post_review]
    author = user_post_review.reviewing_user
    post = user_post_review.post

    if user_post_review.is_anonymous?
      body_text = "An anonymous user added a review to one of your posts"
    else
      body_text = "#{author.display_name_untruncated} added a review to one of your posts"
    end

    notification = Notification.new(
        user: target,
        body: body_text,
        link: @@routes.post_user_post_review_path(post, user_post_review),
        triggered_by: :post_review_received
      )
  end

  def self.configure_post_comment_replied_to(target, options)
    post_comment_reply = options[:post_comment_reply]
    author = post_comment_reply.author
    comment = post_comment_reply.post_comment
    post = post_comment_reply.post
    notification = Notification.new(
        user: target,
        body: "#{author.display_name_untruncated} added to a comment's reply thread that you're in",
        link: @@routes.post_comment_replies_path(post, comment),
        triggered_by: :post_comment_replied_to
      )
  end

  def self.configure_post_commented_on(target, options)
    post_comment = options[:post_comment]
    author = post_comment.author
    post = post_comment.post
    notification = Notification.new(
        user: target,
        body: "#{author.display_name_untruncated} commented on your post",
        link: @@routes.post_path(post),
        triggered_by: :post_commented_on
      )
  end
end
