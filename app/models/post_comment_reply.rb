class PostCommentReply < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :post_comment
end
