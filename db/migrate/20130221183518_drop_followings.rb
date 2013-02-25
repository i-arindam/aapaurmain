class DropFollowings < ActiveRecord::Migration
  def up
    drop_table :followings
  end

  def down
    create_table :followings do |t|
      t.references :user
      t.timestamps
    end
  end
end
