class Story < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_action_on_story(params, acting_user)
    story_id, action = params[:story_id], params[:action].pluralize
    new_action = {
      :by => acting_user.name,
      :by_id => acting_user.id
    }

    if action == :comment
      new_action.merge!({
        :text => params[:text],
        :time => params[:time]  
      })
      $r.rpush("story:#{story_id}:#{action}", new_action.to_json)
    else
      $r.lpush("story:#{story_id}:#{action}", new_action.to_json)
    end
  end

  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_comment(params, acting_user)
    story_id, action, comment_number = params[:story_id], params[:action].pluralize, params[:number]
    new_action = {
      :by => acting_user.name,
      :by_id => acting_user.id
    }

    $r.lpush("story:#{story_id}:comments:#{comment_number}:#{action}", new_action.to_json)
  end

  def self.add_new_story(params, user)
    $r.multi do
      sid = $r.incr("story_count")
      $r.hmset("story:#{sid}", :by, user.name, :by_id, user.id, :text, params[:text], :time, time)
      # $r.lpush("user:#{user.id}:feed", sid)
    end
    sid
  end

  def self.get_likes(sid)
    $r.lrange("story:#{sid}:likes", 0, -1).to_json
  end

  def self.get_dislikes(sid)
    $r.lrange("story:#{sid}:dislikes", 0, -1).to_json
  end

  def self.get_comments(sid)
    $r.lrange("story:#{sid}:comments", 0, 9).to_json
  end

  def self.get_all_comments(sid)
    $r.lrange("story:#{sid}:comments", 10, -1).to_json
  end

  def self.get_likes_on_comment(sid, comment_number)
    $r.lrange("story:#{sid}:comments:#{comment_number}:likes", 0, -1)
  end

  def self.get_dislikes_on_comment(sid, comment_number)
    $r.lrange("story:#{sid}:comments:#{comment_number}:dislikes", 0, -1)
  end

end