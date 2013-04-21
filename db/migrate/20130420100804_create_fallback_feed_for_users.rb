class CreateFallbackFeedForUsers < ActiveRecord::Migration
  def change
    create_table :fallback_feed_for_users do |t|
      t.integer :user_id, :limit => 11, :null => false
      t.integer :mode, :limit => 2, :default => 0
      t.timestamps
    end
    add_index :fallback_feed_for_users, :user_id, :unique => true
  end
end
