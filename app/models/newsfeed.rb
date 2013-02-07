class Newsfeed < ActiveRecord::Base

  def self.add_story_to_feeds(story_id, panels)
    $r.multi do
      panels.each do |panel|
        user_ids = $r.smembers("panel:#{panel}:members")
        user_ids.each do |uid|
          $r.lpush("feed:#{uid}", sid)
        end
      end # End panels.each
    end # End r.multi
  end

  def self.get_initial_feed_for(user_id)
    story_ids = $r.lrange("feed:#{user_id}", 0 , 9)
    Story.get_stories(story_ids)
  end

end
