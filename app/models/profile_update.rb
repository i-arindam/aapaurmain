# == Schema Information
#
# Table name: profile_updates
#
#  id         :integer          not null, primary key
#  profile    :text
#  status     :integer          default(0)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProfileUpdate < ActiveRecord::Base
  attr_accessible :profile, :status

  belongs_to :user

  #PROFILE APPROVAL STATUS
  NOT_APPROVED = 0
  APPROVED = 1

end
