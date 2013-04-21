class Newsfeed < ActiveRecord::Base
  
  # Newsfeed modes
  FALLBACK = 0
  ORGANIC_WITH_FALLBACK_FOR_FIRST_FEED = 1
  PURE_ORGANIC = 2


  # Add story id to each members of all panels
  def self.add_story_to_feeds(story_id, panels)
    user_ids = Set.new
    panels.each do |panel|
      user_ids.merge($r.smembers("panel:#{panel}:members"))
    end
    user_ids = user_ids.to_a
    user_ids.each do |uid|
      $r.lpush("feed:#{uid}", story_id)
    end
  end

  # Case 1: user has 0 panels
  # Feed = pure fallback
  # more = pure fallback from offset
  # Case 2: user has panels
  #   a) not enough stories from panels ( < 10 )
  #      Feed = mixed (all from panels + remaining fallback upto a max of total 20)
  #      User indicated he does not have enough stories.
  #      More = fallback with indication
  #   b) enough stories for initial feed ( >= 10 )
  #      Feed = all from panel
  #      More = leftover from panels + fallback with indication
  def self.get_initial_feed_for(user_id)
    panels = $r.smembers("user:#{user_id}:panels")
    story_ids = []
    if panels.blank? # Case 1
      FallbackFeedForUser.mark_as_fallback_feed_recipient(FALLBACK, user_id)
      story_ids = FallbackFeedForUser.get_pure_fallback_stories(user_id, 0)
      fallback_mode = FALLBACK
    else # Case 2
      story_ids = self.get_organic_stories(user_id, 0)
      if story_ids.length < 10 # Case 2a
        FallbackFeedForUser.mark_as_fallback_feed_recipient(ORGANIC_WITH_FALLBACK_FOR_FIRST_FEED, user_id)
        story_ids = FallbackFeedForUser.get_mixed_fallback_stories(user_id, story_ids)
        fallback_mode = ORGANIC_WITH_FALLBACK_FOR_FIRST_FEED
      else # Case 2b
        FallbackFeedForUser.mark_as_fallback_feed_recipient(PURE_ORGANIC, user_id)
        fallback_mode = PURE_ORGANIC
      end
    end
    story_ids.sort!.reverse!
    [Story.get_stories(story_ids), fallback_mode]
  end

  # Depending on user's fallback mode, return stories
  # 1 - no more stories, red indicator
  # 2a - fallback stories, orange indicator
  # 2b - mixed if needed, red indicator if nothing more
  def self.get_more_feed_for(user_id, start = 10)
    user_feed_mode = FallbackFeedForUser.get_fallback_mode(user_id)
    story_ids, feed_mode = [], nil
    case user_feed_mode
    when FALLBACK # 1
      story_ids = FallbackFeedForUser.get_pure_fallback_stories(user_id, start)
    when ORGANIC_WITH_FALLBACK_FOR_FIRST_FEED # 2a
      story_ids = FallbackFeedForUser.get_pure_fallback_stories(user_id, start)
    when PURE_ORGANIC # 2b
      story_ids = self.get_organic_stories(user_id, start)
      if story_ids.length < 10
        story_ids = FallbackFeedForUser.get_mixed_fallback_stories(user_id, story_ids, start)
        user_feed_mode = ORGANIC_WITH_FALLBACK_FOR_FIRST_FEED
      end
    end
    story_ids.sort!.reverse!
    [Story.get_stories(story_ids), user_feed_mode]
  end

  def self.get_organic_stories(user_id, start)
    panels = $r.smembers("user:#{user_id}:panels")
    story_ids = []
    panel_ids = panels.inject([]) do |arr, panel|
      arr.push(Panel::PANEL_NAME_TO_ID[panel])
    end
    story_ids = StoryPointer.find(:all, :conditions => ["panel_id IN (?)", panel_ids], :order => "id DESC", :limit => 10, :offset => start, :select => "distinct(story_id)").collect(&:story_id)
  end

end
