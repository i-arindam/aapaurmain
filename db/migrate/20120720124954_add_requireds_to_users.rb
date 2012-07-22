class AddRequiredsToUsers < ActiveRecord::Migration
  def change
    change_column :users, :dob, :date, :null => true
    change_column :users, :sex, :string, :limit => 2, :null => true
    add_column :users, :email, :string, :null => false, :limit => 128
  end
end
