class AddIpAddressArrayToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ip_address_array, :string, null: true
  end
end
