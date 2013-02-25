class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :user_follows do |t|
      t.references :user
      t.integer :following_user_id, :limit => 11, :null => false
      t.integer :follow_type, :limit => 1, :default => 0
      t.timestamps
    end
    add_index :user_follows, [:user_id, :following_user_id], :unique => true
  end
end
