class DropTableLock < ActiveRecord::Migration
  def up
    drop_table :locks
  end

  def down
    create_table :locks do |t|
      t.integer :one_id, :limit => 11, :null => false
      t.integer :another_id, :limit => 11, :null => false
      t.date :creation_date, :date
      t.date :withdraw_date, :date
      t.date :finalize_date, :date
      t.integer :status, :limit => 1, :default => 0
    end
    add_index :locks, :one_id
    add_index :locks, :another_id
  end
end
