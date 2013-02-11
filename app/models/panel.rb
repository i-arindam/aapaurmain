class Panel < ActiveRecord::Base

  # Add new story to each panels story set
  def self.add_new_story_to(panels, sid)
    $r.pipelined do
      panels.each do |panel|
        $r.lpush("panel:#{panel}:stories", sid)
      end
    end
  end

  def self.get_common_and_other_panels_for(his_id, my_id)
    common_panels = remaining_panels = []
    $r.multi do
      common_panels = $r.sinter("user:#{his_id}:panels", "user:#{my_id}:panels").value
      remaining_panels = $r.sdiff("user:#{his_id}:panels", "user:#{my_id}:panels").value
    end
    [common_panels, remaining_panels]
  end

end
