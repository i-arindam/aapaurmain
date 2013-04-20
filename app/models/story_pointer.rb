class StoryPointer < ActiveRecord::Base
  attr_accessible :story_id, :user_id, :panel_id

  def self.add_new_story_reference(sid, uid, panels = [])
    return if panels.blank? or sid.blank? or uid.blank?
    panels.each do |panel|
      panel_id = Panel::PANEL_NAME_TO_ID[panel]
      StoryPointer.create({
        :panel_id => panel_id,
        :story_id => sid,
        :user_id => uid  
      })
    end
  end

  def self.delete_story_references(sid, uid, panels = [])
    panels.each do |panel|
      panel_id = Panel::PANEL_NAME_TO_ID[panel]
      story_pointers = StoryPointer.where("story_id = ?  AND user_id = ? AND panel_id = ?", sid, uid, panel_id)
      story_pointers.delete_all
    end
    self.readjust_users_participation_in_panels(uid)
  end

  def self.readjust_users_participation_in_panels(uid)
    remaining_panel_ids = StoryPointer.find(:all, :conditions => ["user_id = ?", uid], :select => "DISTINCT(panel_id)" )
    remaining_panels = remaining_panel_ids.inject([]) do |arr, pid|
      Panel::PANEL_ID_TO_NAME[pid]
    end
    $r.multi do
      $r.del("user:#{uid}:panels")
      $r.sadd("user:#{uid}:panels", remaining_panels)
    end
  end

end
