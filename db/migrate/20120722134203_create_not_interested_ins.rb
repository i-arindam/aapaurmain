class CreateNotInterestedIns < ActiveRecord::Migration
  def change
    create_table :not_interested_in do |t|
      t.integer :user_id
      t.string :not_interested

      t.timestamps
    end
    add_index :not_interested_in, :user_id
    add_index :not_interested_in, :not_interested
  end
end
