class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer     :from_id,     :null => false, :limit => 11
      t.integer     :to_id,       :null => false, :limit => 11
      t.integer     :status,      :default => 0, :limit => 1
      t.datetime    :approved_date
      t.datetime    :rejected_date
      t.datetime    :asked_date
      t.datetime    :withdraw_date
      
      t.timestamps
    end
    
    add_index :requests, :from_id
    add_index :requests, :to_id
  end
end
