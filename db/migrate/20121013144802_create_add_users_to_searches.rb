class CreateAddUsersToSearches < ActiveRecord::Migration
  def change
    create_table :add_users_to_searches do |t|
      t.string  :name,                          :limit => 50, :null => false
      t.integer :family_preference,             :limit => 2
      t.integer :spouse_preference,             :limit => 2
      t.string  :further_education_plans,       :limit => 500
      t.string  :settle_else,                   :limit => 500
      t.integer :sexual_preference,             :limit =>2, :default => 0
      t.string  :virginity_opinion,             :limit => 500
      t.string  :hobbies,                       :limit => 500
      t.integer :profession,                    :limit => 2
      t.string  :dream_for_future,              :limit => 500
      t.string  :settled_in

      t.timestamps
    end
  end
end
