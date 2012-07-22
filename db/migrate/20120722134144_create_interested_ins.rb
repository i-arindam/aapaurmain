class CreateInterestedIns < ActiveRecord::Migration
  def change
    create_table :interested_in do |t|
      t.integer :user_id
      t.string :interested

      t.timestamps
    end
    add_index :interested_in, :user_id
    add_index :interested_in, :interested
  end
end
