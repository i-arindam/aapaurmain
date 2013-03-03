class UserFollow < ActiveRecord::Base
  attr_accessible :following_user_id
  belongs_to :user

  # Follow type
  PUBLICLY = 0
  SILENTLY = 1
end
