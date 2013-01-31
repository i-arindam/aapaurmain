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

end
