class SeedCategories < ActiveRecord::Migration[5.2]
  def self.up
    Category.create!(title: "Writing")
    Category.create!(title: "Design")
    Category.create!(title: "Editing")
    Category.create!(title: "Promotional")
    Category.create!(title: "Miscellaneous")
  end

  def self.down
    Category.destroy_all
  end
end
