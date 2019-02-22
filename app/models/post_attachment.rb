class PostAttachment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_one_attached :document

  validates :description, length: { maximum: 256, allow_blank: true, allow_nil: true }
  validate :document_file_size_acceptable

  def is_image_previewable?
    document.attached? and document.content_type.in?(["image/x-png", "image/png", "image/jpeg", "image/bmp"])
  end

  def filename
    document&.filename&.to_s
  end

  def short_filename
    document.filename.base.truncate(60) + "." + document.filename.extension
  end

  def document_file_size_acceptable
    if document.attached?
      if document.blob.byte_size > 4 * 1000 * 1000 # 4 megabytes (BYTE, not BIT)
        document.purge
        errors.add(:document, "is over the maximum allowed size of 4MB. Please choose a smaller file.")
      end
    end
  end
end