class AddRatingFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :num_ratings, :integer, :limit => 11, :default => 0
    add_column :users, :avg_rating, :decimal, :precision => 4, :scale => 2, :default => 0.0
  end
end
