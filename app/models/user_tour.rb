class UserTour < ActiveRecord::Base
  attr_accessible :user_id, :tour_count
  belongs_to :user
end
