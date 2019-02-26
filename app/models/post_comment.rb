class PostComment < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :post

  has_many :post_comment_replies, dependent: :destroy

  validates :body, presence: true
end
