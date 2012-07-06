class UserFlag < ActiveRecord::Base
  belongs_to :user
  
  # Enumeration for user flag table when user is suspended/unsuspended.
  SUSPENDED = 1
  MARKED_FOR_DELETION = 2
end
