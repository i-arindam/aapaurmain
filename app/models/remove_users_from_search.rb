# == Schema Information
#
# Table name: remove_users_from_searches
#
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RemoveUsersFromSearch < ActiveRecord::Base
  attr_accessible :user_id
end
