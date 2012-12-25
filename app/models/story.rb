class Story < ActiveRecord::Base
  # attr_accessible :title, :body
  
  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_action_on_story(params, acting_user)
    story_id, action = params[:story_id], params[:action]
    action_count = action.to_s + "_count"
    actions = action.to_s.pluralize
    new_action = {
      :by => acting_user.name,
      :by_id => acting_user.id
    }

    if action == :comment
      new_action.merge!({
        :text => params[:text],
        :time => params[:time]  
      })
    end

    $r.multi do 
      $r.hincr("story:#{story_id}", action_count)
      $r.rpush("story:#{story_id}:#{actions}", new_action.to_json)
    end
  end

  # Update the like, dislike, comment action on story
  # @param [Hash] params
  #   Passed params from view
  # @param [Object::User] acting_user
  #   Current user who did action
  def self.update_comment(params, acting_user)
    story_id, action, comment_number = params[:story_id], params[:action], params[:comment_number]
    action_count = "comment_#{action.to_s}_count"
    actions = "comment_#{action.to_s.pluralize}"
    new_action = {
      :by => acting_user.name,
      :by_id => acting_user.id
    }

    # Modify the comment. Add like, Add like details
    $r.multi do
      $r.hincr($r.lindex( "story:#{story_id}:comments", comment_number), action_count)
      $r.rpush($r.hget($r.lindex( "story:#{story_id}:comments", comment_number), actions), new_action.to_json)
    end
  end

end
