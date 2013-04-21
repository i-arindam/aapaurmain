class FallbackFeedForUser < ActiveRecord::Base
  attr_accessible :user_id

  def self.get_fallback_mode(user_id)
    u = FallbackFeedForUser.find_by_user_id(user_id)
    u && u.mode
  end

  def self.mark_as_fallback_feed_recipient(mode, user_id)
    fallback_user = FallbackFeedForUser.find_or_create_by_user_id(user_id)
    fallback_user.mode = mode
    fallback_user.save
  end

  def self.get_pure_fallback_stories(user_id, start = 0)
    StoryPointer.find(:all, :conditions => [ "user_id != ?", user_id], :order => "id DESC", :limit => 10, :offset => start, :select => "DISTINCT(story_id)").collect(&:story_id)
  end

  def self.get_mixed_fallback_stories(user_id, available_sids, start = 0)
    num_stories = 10 - available_sids.length
    fallback_stories = StoryPointer.find(:all, :conditions => [ "story_id NOT IN (?)", available_sids ], :order => "id DESC", :limit => num_stories, :offset => start, :select => "DISTINCT(story_id)").collect(&:story_id)
    fallback_stories + available_sids
  end
end
