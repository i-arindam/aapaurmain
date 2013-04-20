class CreateStoryPointers < ActiveRecord::Migration
  def change
    create_table :story_pointers do |t|
      t.integer :panel_id, :limit => 11, :null => false
      t.integer :user_id, :limit => 11, :null => false
      t.integer :story_id, :limit => 11, :null => false

      t.timestamps
    end
    add_index :story_pointers, :panel_id
    add_index :story_pointers, [:user_id, :panel_id]
    add_index :story_pointers, :story_id 
  end
end
