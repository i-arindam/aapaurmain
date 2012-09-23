class AddPhotoExistsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :photo_exists, :boolean
  end
end
