class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy

  def self.search_options
    options = []
    self.all.order(:id).each do |cat|
      puts "Inserting #{cat.title}"
      options << ["All #{cat.title}", "#{cat.id}"]
      cat.subcategories.order(:id).each do |s|
        puts "Inserting #{s.title}"
        options << ["[#{cat.title}] #{s.title}", "#{cat.id}-#{s.id}"]
      end
    end
    options
  end

  def self.pricing_type_words
    type_words = {}
    self.all.each do |cat|
      type_words[cat.id] = "booking"
      cat.subcategories.each{ |s| type_words["#{cat.id}-#{s.id}"] = s.pricing_type }
    end
    json_ready_string(type_words)
  end

  def self.json_ready_string(ruby_hash)
    "{#{ruby_hash.map{ |k, v| "'#{k}': '#{v}'" }.join(", ")}}".html_safe
  end
end