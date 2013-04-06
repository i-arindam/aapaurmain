class Story < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_action_on_story(params, acting_user_id)
    story_id, action = params[:story_id], params[:work].pluralize
    already_acted = $r.sismember("story:#{story_id}:#{action}", acting_user_id)

    return false if already_acted
    $r.sadd("story:#{story_id}:#{action}", acting_user_id)
    return true
  end

  def self.add_comment(params, user)
    story_id, text = params[:story_id], params[:text].gsub("\n", "<br/>")
    comment_object = StoryComment.create({
      :by => user.name,
      :by_id => user.id,
      :text => text,
      :story_id => story_id,
      :photo_url => user.image('small')
    })

    $r.rpush("story:#{story_id}:comments", comment_object.id)
    comment_object
  end

  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_comment(params, acting_user_id)
    story_id, action, comment_number = params[:story_id], params[:work].pluralize, params[:number]
    already_acted = $r.sismember("story:#{story_id}:comments:#{comment_number}:#{action}", acting_user_id)

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
      $r.lpush("user:#{user.id}:stories", sid)
    end
    sid
  end

  def self.get_claps(sid)
    $r.smembers("story:#{sid}:claps")
  end

  def self.get_boos(sid)
    $r.smembers("story:#{sid}:boos")
  end

  def self.get_comments(sid, start, stop)
    comment_ids = $r.lrange("story:#{sid}:comments", start, stop)
    comments = StoryComment.find_all_by_id(comment_ids)
    final_comments, i = {}, 0
    comments.each do |com|
      final_comments[com.id] = {
        :comment => com,
        :claps => $r.scard("story:#{sid}:comments:#{com.id}:claps") || 0,
        :boos => $r.scard("story:#{sid}:comments:#{com.id}:boos") || 0
      }
      final_comments[com.id][:comment][:text] = ActionController::Base.helpers.auto_link(com.text, :html => { :target => '_blank' })
    end
    final_comments
  end

  def self.get_all_comments(sid)
    $r.lrange("story:#{sid}:comments", 10, -1)
  end

  def self.get_claps_on_comment(sid, comment_number)
    $r.smembers("story:#{sid}:comments:#{comment_number}:claps")
  end

  def self.get_boos_on_comment(sid, comment_number)
    $r.smembers("story:#{sid}:comments:#{comment_number}:boos")
  end

  # @param [Array] sids
  #         list of ids of stories to be shown
  # @return [Array of Hash]
  #         Array of stories in the order asked.
  # Each element in the array is a hash containing all count and text info of the story
  def self.get_n_stories_for(user_id, n = 2, start = 0)
    sids = []
    sids = $r.lrange("user:#{user_id}:stories", start, n)
    stories = self.get_stories(sids)
  end

  def self.get_stories(sids)
    stories = []
    sids.each do |sid|
      story = {}
      story['core'] = $r.hgetall("story:#{sid}")
      unless story['core'].blank?
        $r.multi do
          story['claps'] = $r.scard("story:#{sid}:claps")
          story['boos'] = $r.scard("story:#{sid}:boos")
          story['comments'] = $r.llen("story:#{sid}:comments")
          story['panels'] = $r.smembers("story:#{sid}:panels")
        end
        story.each do |k,v|
          story[k] = v.value unless k == 'core'
        end
        story.merge!(story['core'])
        story.merge!({'id' => sid})
        story.delete("core")
        story['text'].gsub!("\n", "<br/>")
        story['text'] = ActionController::Base.helpers.auto_link(story['text'], :html => { :target => '_blank' })
        stories.push(story)
      end
    end
    stories
  end

  def self.decorate_time(time)
    view_context.distance_of_time_in_words_to_now(time)
  end


end
