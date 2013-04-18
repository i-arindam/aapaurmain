class CreateUserTours < ActiveRecord::Migration
  def change
    create_table :user_tours do |t|
      t.integer :user_id, :null => false, :limit => 11
      t.integer :tour_count, :default => 0

      t.timestamps
    end
    add_index :user_tours, :user_id
  end
end
