class ProfileViewer < ActiveRecord::Base
  attr_accessible :viewer_id, :profile_id
end
