class CreateCouple < ActiveRecord::Migration
  def change
    create_table :couples do |t|
      t.integer :one_id, :null => false, :limit => 11
      t.integer :another_id, :null => false, :limit => 11
      t.integer :deliberation_time, :limit => 2
      
      t.timestamps
    end
  end
end
