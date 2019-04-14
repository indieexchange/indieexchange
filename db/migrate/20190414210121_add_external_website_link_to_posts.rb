class AddExternalWebsiteLinkToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :external_website_link, :string, limit: 500
  end
end
