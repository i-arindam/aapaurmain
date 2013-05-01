class AddThumbnailExistsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :thumbnail_exists, :boolean, :default => nil
  end
end
