class StoryComment < ActiveRecord::Base
  attr_accessible :text, :by, :by_id, :story_id, :photo_url
end
