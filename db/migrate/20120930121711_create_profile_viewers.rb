class CreateProfileViewers < ActiveRecord::Migration
  def change
    create_table :profile_viewers do |t|
      t.integer :profile_id, :limit => 11, :null => false
      t.integer :viewer_id, :limit => 11, :null => false
      
      t.timestamps
    end
    add_index :profile_viewers, :profile_id
  end
end
