class NotInterestedIn < ActiveRecord::Base
  attr_accessible :not_interested, :user_id
  set_table_name "not_interested_in"
end
