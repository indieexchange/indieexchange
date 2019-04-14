class UpdatePrecisionOfPostPrice < ActiveRecord::Migration[5.2]
  def change
    change_column :posts, :price, :decimal, precision: 12, scale: 4
  end
end
