class Post < ApplicationRecord
  belongs_to :subcategory
  belongs_to :user
  has_many   :post_attachments, dependent: :destroy

  validates :title,       presence: true, length: { maximum: 128 }
  validates :description, presence: true, length: { maximum: 8192 }
  validates :price,       presence: true, numericality: { greater_than: 0, less_than: 1_000_000 }

  scope :offering,  proc{ |offering_status| where(is_offering: offering_status) unless offering_status.nil? }
  scope :subcat,    proc{ |subcategory_id| where(subcategory_id: subcategory_id) unless subcategory_id.nil? }
  scope :max_price, proc{ |max_price| where("price <= ?", max_price) unless max_price.nil? }
  scope :keywords,  proc{ |words| where(words.map{ |w| "(title ILIKE ? OR description ILIKE ?)" }.
                                  join(" AND "),
                                  *words.collect{ |w| ["%#{w}%", "%#{w}%"] }.flatten) unless words.nil? }
  scope :published, -> { where(is_published: true) }
  scope :visible,   -> { where(is_visible: true) }

  def self.seeking_options
    [["Services offered by others", false],["People who need my services", true]]
  end

  def hidden?
    (!is_published) or (!is_visible)
  end

  def offering_word
    is_offering ? "Offering" : "Seeking"
  end

  def bump
    if is_bumpable?
      update!(last_update_bump_at: Time.now)
    else
      return false
    end
  end

  def is_bumpable?
    last_update_bump_at.nil? or (last_update_bump_at < (Time.now - 72.hours))
  end

  def hours_to_bump
    (((last_update_bump_at + 72.hours) - Time.now)/(1.hour)).round
  end
end