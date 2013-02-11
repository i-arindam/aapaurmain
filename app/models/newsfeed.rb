class Newsfeed < ActiveRecord::Base

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

  def self.get_initial_feed_for(user_id)
    story_ids = $r.lrange("feed:#{user_id}", 0 , 9)
    Story.get_stories(story_ids)
  end

end
