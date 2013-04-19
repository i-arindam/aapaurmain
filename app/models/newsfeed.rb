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
    show_all = $r.llen("feed:#{user_id}").to_i < 5
    if(show_all)
      sids = $r.get("story_count").to_i
      story_ids = []
      sids.downto(1) do |i|
        if($r.type("story:#{i}") != "none")
          story_ids.push(i)
        end
      end
      story_ids = story_ids[0...10]
    else
      story_ids = $r.lrange("feed:#{user_id}", 0 , 9)
    end
    Story.get_stories(story_ids)
  end

  def self.get_more_feed_for(user_id, sids = [])
    story_ids = $r.lrange("feed:#{user_id}", 0, -1)
    final_story_ids = story_ids - sids
    Story.get_stories(final_story_ids)
  end

end
