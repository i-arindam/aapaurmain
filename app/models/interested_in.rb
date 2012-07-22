class InterestedIn < ActiveRecord::Base
  attr_accessible :interested, :user_id
  set_table_name :interested_in
end
