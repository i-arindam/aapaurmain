class ProfileRating < ActiveRecord::Base
  attr_accessible :rated_user_id, :score
  belongs_to :user
end
