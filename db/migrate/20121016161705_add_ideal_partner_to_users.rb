class AddIdealPartnerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ideal_partner, :string, :limit => 500
  end
end
