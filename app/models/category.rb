class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy

  def self.search_options
    options = []
    self.all.order(:id).each do |cat|
      options << ["#{cat.title}", "#{cat.id}"]
      cat.subcategories.order(:id).each do |s|
        options << ["#{cat.title} - #{s.title}", "#{cat.id}-#{s.id}"]
      end
    end
    options << ["All Posts", "all"]
    options
  end

  def self.id_for(title)
    find_by_title(title).id
  end

  def self.pricing_type_words
    type_words = {}
    self.all.each do |cat|
      type_words[cat.id] = "booking"
      cat.subcategories.each{ |s| type_words["#{cat.id}-#{s.id}"] = s.pricing_type }
    end
    type_words["all"] = "booking"
    json_ready_string(type_words)
  end

  def self.json_ready_string(ruby_hash)
    "{#{ruby_hash.map{ |k, v| "'#{k}': '#{v}'" }.join(", ")}}".html_safe
  end
end