class UpdateIsVisibleDefaultForPosts < ActiveRecord::Migration[5.2]
  def change
    change_column_default :posts, :is_visible, true
  end
end
