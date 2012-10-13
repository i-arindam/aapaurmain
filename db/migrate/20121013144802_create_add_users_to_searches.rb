class CreateAddUsersToSearches < ActiveRecord::Migration
  def change
    create_table :add_users_to_searches do |t|

      t.timestamps
    end
  end
end
