class CreateRemoveUsersFromSearches < ActiveRecord::Migration
  def change
    create_table :remove_users_from_searches, :id => false do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end
