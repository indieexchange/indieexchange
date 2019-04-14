class AddNumberOfViewsToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :number_of_views, :integer, nil: false, default: 0
  end
end
