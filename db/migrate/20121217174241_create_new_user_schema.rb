class CreateNewUserSchema < ActiveRecord::Migration
  def change

    # drop_table :profile_viewers
    # drop_table :hobbies
    # drop_table :interested_in
    # drop_table :not_interested_in
    # drop_table :susbcriptions
    # drop_table :user_flags

    cols = []
    User.columns.collect(&:name).each do |col|
     cols.push(col.to_sym)
    end
    cols = cols - [:id]
    remove_column :users, cols

    # Basic data
    add_column :users, :email,                    :string, :null => false
    add_column :users, :name,                     :string, :null => false, :limit => 150
    add_column :users, :dob,                      :date
    add_column :users, :location,                 :string
    add_column :users, :password_reset_token,     :string, :limit => 255
    add_column :users, :password_reset_sent_at,   :date
    add_column :users, :password_digest,          :string, :null => false, :limit => 255
    add_column :users, :auth_token,               :string, :limit => 255
    add_column :users, :sex,                      :integer, :limit => 1

    # Priorities
    add_column :users, :relocation,               :string, :limit => 140
    add_column :users, :joint_family,             :string, :limit => 140
    add_column :users, :inlaws_interference,      :string, :limit => 140
    add_column :users, :further_education,        :string, :limit => 140
    add_column :users, :kids,                     :string, :limit => 140
    add_column :users, :opinion_on_sex,           :string, :limit => 140
    add_column :users, :gender_expectations,      :string, :limit => 140
    add_column :users, :primary_bread_winner,     :string, :limit => 140
    add_column :users, :independence,             :string, :limit => 140
    add_column :users, :career_priority,          :string, :limit => 140
    add_column :users, :financial_stability,      :string, :limit => 140
    add_column :users, :romance,                  :string, :limit => 140
    add_column :users, :interests,                :string, :limit => 140
    add_column :users, :virginity,                :string, :limit => 140
    add_column :users, :chivalry,                 :string, :limit => 140
    add_column :users, :decisiveness,             :string, :limit => 140
    add_column :users, :family_background,        :string, :limit => 140

    # Old Data
    add_column :users, :short_bio,                :string, :limit => 500
    add_column :users, :photo_url,                :string
    add_column :users, :photo_exists,             :boolean
    add_column :users, :email_verified,           :boolean
    add_column :users, :locked_since,             :date
    add_column :users, :locked_with,              :integer, :limit => 11
    add_column :users, :status,                   :boolean, :limit => 1
    
    add_column :users, :created_at,               :datetime, :null => false
    add_column :users, :updated_at,               :datetime, :null => false

    add_index :users, :email
    add_index :users, :password_reset_token
    add_index :users, :location
    add_index :users, :auth_token
  end
end
