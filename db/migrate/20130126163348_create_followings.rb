class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.references :user
      t.timestamps
    end
  end
end
