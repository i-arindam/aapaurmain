class AddStatusToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :status, :integer, :limit => 1, :default => 0
  end
end
