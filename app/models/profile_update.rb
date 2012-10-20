class ProfileUpdate < ActiveRecord::Base
  attr_accessible :profile, :status

  belongs_to :user

  #PROFILE APPROVAL STATUS
  NOT_APPROVED = 0
  APPROVED = 1

end
