class MakeNameNullableInUsers < ActiveRecord::Migration
  def change
    change_column :users, :name, :string, :limit => 50, :null => true
  end
end
