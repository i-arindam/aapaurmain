class ProfileUpdate < ActiveRecord::Base
  attr_accessible :profile, :status

  belongs_to :user

  #PROFILE APPROVAL STATUS
  APPROVED = 0
  NOT_APPROVED = 1

end
