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
    { panel => users }
  end

  def self.get_popular_users_from_panels_of(user_id)
    panels = $r.smembers("user:#{user_id}:panels")
    if panels.blank?
      fallback_panel_ids = StoryPointer.find(:all, :select => "DISTINCT(panel_id)", :order => "id DESC", :limit => 3).collect(&:panel_id)
      panels = fallback_panel_ids.inject([]) do |arr, fb_pid|
        arr.push(PANEL_ID_TO_NAME[fb_pid])
      end
    end
    panel_users_hash = panels.inject({}) do |hash, panel|
      panel_uids = $r.smembers("panel:#{panel}:members")
      next if panel_uids.blank?
      uids = panel_uids.inject([]) do |arr, u|
        arr.push(u.to_i)
      end - [user_id]
      uids = uids.sort.reverse[0...6]
      users = User.find_all_by_id(uids)
      hash[panel] = users
      hash
    end
  end
end
