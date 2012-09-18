class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :from_user_id, :null => false, :limit => 11
      t.integer :to_user_id, :null => false, :limit => 11
      t.timestamps
    end
    add_index :conversations, :from_user_id
    add_index :conversations, :to_user_id
  end
end
