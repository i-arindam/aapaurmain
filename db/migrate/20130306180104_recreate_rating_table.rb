class RecreateRatingTable < ActiveRecord::Migration
  def change
    create_table :profile_ratings do |t|
      t.integer :user_id, :limit => 11, :null => false
      t.integer :rated_user_id, :limit => 11, :null => false
      t.integer :score, :limit => 1, :default => 0

      t.timestamps
    end
    add_index :profile_ratings, [:rated_user_id, :user_id], :unique => true
  end
end
