class AnnouncementReply < ApplicationRecord
  belongs_to :announcement
  belongs_to :user

  validates :body, presence: true
end
