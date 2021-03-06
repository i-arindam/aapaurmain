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
    if action == "claps"
      if $r.sismember("story:#{story_id}:boos", acting_user_id)
        $r.srem("story:#{story_id}:boos", acting_user_id)
        like_dislike_reversed = true
      end
    elsif action == "boos"
      if $r.sismember("story:#{story_id}:claps", acting_user_id)
        $r.srem("story:#{story_id}:claps", acting_user_id) 
        like_dislike_reversed = true
      end
    end
    $r.sadd("story:#{story_id}:#{action}", acting_user_id)
    return [true, like_dislike_reversed]
  end

  def self.add_comment(params, user)
    story_id, text = params[:story_id], params[:text].gsub("\n", "<br/>")
    comment_object = StoryComment.create({
      :by => user.name,
      :by_id => user.id,
      :text => text,
      :story_id => story_id,
      :photo_url => user.image('thumb')
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

    if action == "deletes"
      $r.lrem("story:#{story_id}:comments", 0, comment_number)
      $r.del("story:#{story_id}:comments:#{comment_number}:claps", "story:#{story_id}:comments:#{comment_number}:boos")
      StoryComment.find_by_id(comment_number).destroy
      return true
    else
      return false if already_acted
      if action == "claps"
        key = "story:#{story_id}:comments:#{comment_number}:boos"
        if $r.sismember(key, acting_user_id)
          $r.srem(key, acting_user_id)
          like_dislike_reversed = true
        end
      elsif action == "boos"
        key = "story:#{story_id}:comments:#{comment_number}:claps"
        if $r.sismember(key, acting_user_id)
          $r.srem(key, acting_user_id)
          like_dislike_reversed = true
        end
      end
          
      $r.sadd("story:#{story_id}:comments:#{comment_number}:#{action}", acting_user_id)
      return [true, like_dislike_reversed]
    end
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

  def self.get_comments(sid, start, stop, descending = false)
    comments = StoryComment.find(:all, :conditions => ["story_id = ?",sid], :order => "id #{descending ? 'DESC' : 'ASC'}", :offset => start, :limit => stop)
    comments.reverse! if descending
    final_comments, i = {}, 0
    comments.each do |com|
      final_comments[com.id] = {
        :comment => com,
        :author_photo => User.find_by_id(com.by_id).image('thumb'),
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

  def self.get_claps_on_comment(sid, comment_id)
    $r.smembers("story:#{sid}:comments:#{comment_id}:claps")
  end

  def self.get_boos_on_comment(sid, comment_id)
    $r.smembers("story:#{sid}:comments:#{comment_id}:boos")
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
          story['comments'] = StoryComment.count(:conditions => {:story_id => sid})
          story['panels'] = $r.smembers("story:#{sid}:panels")
        end
        story.each do |k,v|
          story[k] = v.value unless (k == 'core' || k == 'comments')
        end
        story.merge!(story['core'])
        story.merge!({'id' => sid})
        story.delete("core")
        story['text'].gsub!("\n", "<br/>")
        story['text'] = ActionController::Base.helpers.auto_link(story['text'], :html => { :target => '_blank' })
        author = User.find_by_id(story['by_id'])
        story['author_image'] = author && author.image('thumb')

        comments = Story.get_comments(sid, 0, 3, true)
        story['comment_bodies'] = comments
        stories.push(story)
      end
    end
    stories
  end

  def self.decorate_time(time)
    view_context.distance_of_time_in_words_to_now(time)
  end


end
