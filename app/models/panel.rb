class Panel < ActiveRecord::Base
  PANEL_NAME_TO_ID = $priorities_list['panels_to_id']
  PANEL_ID_TO_NAME = PANEL_NAME_TO_ID.invert

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
      common_panels = $r.sinter("user:#{his_id}:panels", "user:#{my_id}:panels")
      remaining_panels = $r.sdiff("user:#{his_id}:panels", "user:#{my_id}:panels")
    end
    [common_panels.value, remaining_panels.value]
  end

  def self.get_showable_users(panel, current_user_id = nil)
    uids = $r.smembers("panel:#{panel}:members")[0...30]
    uids = uids - [current_user_id.to_s]
    users = User.find_all_by_id(uids)
  end

end
