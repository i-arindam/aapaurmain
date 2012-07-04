class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.date        :start_date,            :null => false
      t.date        :end_date,              :null => false
      t.integer     :subs_type,             :limit => 1, :default => 0
      t.date        :remind_date_start
      t.references  :user
      t.date        :renew_date
      t.integer     :renew_type,            :limit => 1, :default => 0
      
      t.timestamps
    end
    
    execute <<-SQL
      ALTER TABLE subscriptions 
      ADD CONSTRAINT fk_subscriptions_users
      FOREIGN KEY (user_id)
      REFERENCES users(id)
    SQL
    add_index :subscriptions, :remind_date_start
    add_index :subscriptions, :end_date
  end
end
