class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :status, :integer, :limit => 1, :default => 0
    add_column :users, :locked_since, :date
    add_column :users, :locked_with, :integer
    add_column :users, :email_verified, :boolean, :default => false
  end
end
