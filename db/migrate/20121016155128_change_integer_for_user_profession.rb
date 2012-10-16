class ChangeIntegerForUserProfession < ActiveRecord::Migration
  
 def change
  change_column :users, :profession, :string, :limit => 255
 end

end
