class Subcategory < ApplicationRecord
  # note: there are three pricing types.
  # "word" [DEFAULT]
  # "unit"
  # "project"
  # any pricing types other than these will be rejected
  belongs_to :category
  has_many :posts, dependent: :destroy

  validate :pricing_type_is_acceptable

  def self.pricing_type_words
    type_words = {}
    self.all.each{ |s| type_words[s.id] = s.pricing_type}
    json_ready_string(type_words)
  end

  def self.selection_options
    self.all.order(:id).map{ |s| ["#{s.category.title} > #{s.title}", s.id] }
  end

  def self.json_ready_string(ruby_hash)
    "{#{ruby_hash.map{ |k, v| "'#{k}': '#{v}'" }.join(", ")}}".html_safe
  end

  def pricing_type_is_acceptable
    unless ["word", "booking", "hour"].include?(pricing_type)
      errors.add(:pricing_type, "must be 'word', 'booking', or 'hour'")
    end
  end
end