class UserFollow < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  # Follow type
  PUBLICLY = 0
  SILENTLY = 1
end
