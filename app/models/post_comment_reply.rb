class PostCommentReply < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :post_comment

  after_create :notify_comment_author

  def notify_comment_author
    # we should notify everyone in the thread, minus the person who wrote it
    recipient_ids = PostComment.includes(:post_comment_replies).
                                find(self.post_comment_id).post_comment_replies.map(&:author_id).
                                uniq.reject{ |author_id| author_id == author.id }
    recipient_ids.each do |recipient_id|
      Notification.configure!(:post_comment_replied_to, User.find(recipient_id), {post_comment_reply: self})
    end
  end
end
