class Panel < ActiveRecord::Base

  def self.add_new_story_to(panels, sid)
    $r.multi do
      panels.each do |panel|
        $r.lpush("panel:#{panel}:stories", sid)
      end
    end
  end

end
