class AddRecommendedUserIdsToUser < ActiveRecord::Migration
  def change
    add_column :users, :recommended_user_ids, :string, :limit => 250
  end
end
