class Story < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_action_on_story(params, acting_user_id)
    story_id, action = params[:story_id], params[:work].pluralize
    already_acted = $r.sismember("story:#{story_id}:action", acting_user.id)

    return false if already_acted
    $r.sadd("story:#{story_id}:action", acting_user_id)
    return true
  end

  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_comment(params, acting_user_id)
    story_id, action, comment_number = params[:story_id], params[:action].pluralize, params[:number]
    already_acted = $r.sismember("story:#{story_id}:comments:#{comment_number}:#{action}", acting_user.id)

    return false if already_acted
    $r.sadd("story:#{story_id}:comments:#{comment_number}:#{action}", acting_user_id)
    return true
  end

  # Add new story. Increment story count
  # Add all panels to this story panels set
  def self.add_new_story(params, user)
    sid = $r.incr("story_count")
    time = Time.new
    $r.multi do
      $r.hmset("story:#{sid}", :by, user.name, :by_id, user.id, :text, params[:text], :time, time)
      $r.sadd("story:#{sid}:panels", params[:panels])
    end
    sid
  end

  def self.get_claps(sid)
    $r.lrange("story:#{sid}:claps", 0, -1)
  end

  def self.get_boos(sid)
    $r.lrange("story:#{sid}:boos", 0, -1)
  end

  def self.get_comments(sid)
    $r.lrange("story:#{sid}:comments", 0, 9)
  end

  def self.get_all_comments(sid)
    $r.lrange("story:#{sid}:comments", 10, -1)
  end

  def self.get_claps_on_comment(sid, comment_number)
    $r.lrange("story:#{sid}:comments:#{comment_number}:claps", 0, -1)
  end

  def self.get_boos_on_comment(sid, comment_number)
    $r.lrange("story:#{sid}:comments:#{comment_number}:boos", 0, -1)
  end

  # @param [Array] sids
  #         list of ids of stories to be shown
  # @return [Array of Hash]
  #         Array of stories in the order asked.
  # Each element in the array is a hash containing all count and text info of the story
  def self.get_n_stories_for(user_id, n = 2, start = 0)
    sids = []
    sids = $r.lrange("user:#{user_id}:story_ids", start, n)
    stories = self.get_stories(sids)
  end

  def self.get_stories(sids)
    stories = []
    sids.each do |sid|
      story = {}
      $r.multi do
        story['core'] = $r.hgetall("story:#{sid}")
        story['claps'] = $r.llen("story:#{sid}:claps")
        story['boos'] = $r.llen("story:#{sid}:boos")
        story['comments'] = $r.llen("story:#{sid}:comments")
      end
      story.each do |k,v|
        story[k] = v.value
      end
      story.merge!(story['core'])
      story.merge!({'id' => sid})
      story.delete("core")
      stories.push(story)
    end
    stories
  end

end
