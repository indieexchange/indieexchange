class PostComment < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :post

  has_many :post_comment_replies, dependent: :destroy

  validates :body, presence: true

  after_create :notify_post_author

  def notify_post_author
    # note: the post author is the **target** column.  the **author** column is who wrote the post.
    # of course, we want to skip this in case you commented on your own post, which is dumb, but could happen
    if author != target
      Notification.configure!(:post_commented_on, target, {post_comment: self})
    end
  end
end
