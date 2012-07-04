class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name,                          :limit => 50, :null => false
      t.date    :dob,                           :null => false
      t.string  :sex,                           :null => false
      t.integer :family_preference,             :limit => 2
      t.float   :height
      t.integer :spouse_preference,             :limit => 2
      t.integer :spouse_salary,                 :limit => 8
      t.string  :further_education_plans,       :limit => 500
      t.string  :spouse_further_education,      :limit => 500
      t.string  :settle_else,                   :limit => 500
      t.integer :sexual_preference,             :limit =>2, :default => 0
      t.string  :virginity_opinion,             :limit => 500
      t.string  :ideal_marriage,                :limit => 500
      t.integer :salary,                        :limit => 8
      t.string  :hobbies,                       :limit => 500
      t.integer :siblings,                      :limit => 2
      t.integer :profession,                    :limit => 2
      t.string  :dream_for_future,              :limit => 500
      t.string  :interested_in,                 :limit => 500
      t.string  :not_interested_in,             :limit => 500
      t.string  :settled_in
      t.boolean :dont_search,                   :default => false
      t.date    :hidden_since
      
      t.timestamps
    end
    
    add_index :users, :name
    add_index :users, :family_preference
    add_index :users, :spouse_preference
    add_index :users, :profession
    add_index :users, :interested_in
  end
end
