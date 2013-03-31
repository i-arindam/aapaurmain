# == Schema Information
#
# Table name: user_follows
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  following_user_id :integer          not null
#  follow_type       :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class UserFollow < ActiveRecord::Base
  attr_accessible :following_user_id
  belongs_to :user

  # Follow type
  PUBLICLY = 0
  SILENTLY = 1
end
