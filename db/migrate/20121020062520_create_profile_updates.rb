class CreateProfileUpdates < ActiveRecord::Migration
  def change
    create_table :profile_updates do |t|
      t.text :profile
      t.integer :status, :default => 0
      t.integer :user_id

      t.timestamps
    end
  end
end
