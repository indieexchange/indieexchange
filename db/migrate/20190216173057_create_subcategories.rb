class CreateSubcategories < ActiveRecord::Migration[5.2]
  def change
    create_table :subcategories do |t|
      t.belongs_to :category, foreign_key: true, null: false
      t.string :title, null: false
      t.string :pricing_type, null: false, default: "word"
    end
  end
end
