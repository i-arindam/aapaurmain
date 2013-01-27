class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.references :user
      t.timestamps
    end
  end
end
