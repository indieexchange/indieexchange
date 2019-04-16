class SeedSubcategories < ActiveRecord::Migration[5.2]
  def self.up
    Subcategory.create!(category: Category.find_by_title("Writing"),       title: "Ghostwriting",         pricing_type: "word")
    Subcategory.create!(category: Category.find_by_title("Writing"),       title: "Blurb",                pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Writing"),       title: "Plots",                pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Design"),        title: "Cover Art",            pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Design"),        title: "Promotional Graphic",  pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Design"),        title: "Website",              pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Beta Reading",         pricing_type: "word")
    Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Proofreading",         pricing_type: "word")
    Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Copyediting",          pricing_type: "word")
    Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Development",          pricing_type: "word")
    Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Newsletter",           pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Advertising",          pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Advanced Reader Copy", pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Data Services",        pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Virtual Assistant",    pricing_type: "hour")
    Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Formatting",           pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Audiobook Narration",  pricing_type: "booking")
    Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Other",                pricing_type: "booking")
  end

  def self.down
    Subcategory.destroy_all
  end
end
