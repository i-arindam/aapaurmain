class DropProfileRating < ActiveRecord::Migration
  def up
    drop_table :profile_ratings
  end

  def down
    create_table :profile_ratings do |t|
      t.references :user
      t.integer :my_id, :limit => 11, :null => false
      t.integer :rating, :limit => 1, :default => 0

      t.timestamps
    end
    add_index :profile_ratings, [:my_id, :user_id], :unique => true
  end
end
