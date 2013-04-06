class CreateCommentsForStories < ActiveRecord::Migration
  def change
    create_table :story_comments do |t|
      t.string :text, :limit => 2000
      t.string :by
      t.integer :by_id, :limit => 11, :null => false
      t.integer :story_id, :limit => 11, :null => false
      t.string :photo_url

      t.timestamps
    end
    add_index :story_comments, [:story_id, :by_id]
    add_index :story_comments, :by_id
  end
end
