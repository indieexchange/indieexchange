class Announcement < ApplicationRecord
  belongs_to :user
  has_many :announcement_replies, dependent: :destroy

  after_create :set_unread_announcements

  validates :body, presence: true

  def set_unread_announcements
    User.where(is_admin: false).update_all(has_unread_announcement: true)
  end
end
