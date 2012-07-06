class CreateUserFlags < ActiveRecord::Migration
  def change
    create_table :user_flags do |t|
      t.integer     :user_id, :limit => 11, :null => false
      t.integer     :value,   :limit => 2      
      t.timestamps
    end
  
    execute <<-SQL
      ALTER TABLE user_flags 
      ADD CONSTRAINT fk_user_flags_users
      FOREIGN KEY (user_id)
      REFERENCES users(id)
    SQL
  end
  
end
