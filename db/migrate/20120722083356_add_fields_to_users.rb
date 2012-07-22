class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :short_bio, :string, :limit => 500
    add_column :users, :education, :string
    add_column :users, :photo_url, :string
    add_column :users, :blog_url, :string
    change_column :users, :sex, :string, :limit => 10
  end
end
