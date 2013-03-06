class StoryController < ApplicationController

  def like_dislike_or_comment
    render_404 and return unless user = current_user
    res = {}
    if params[:work] == "comment"
      comment = Story.add_comment(params, user)
      comment['when'] = decorate_redis_time(comment['when'])
      comment['text'].gsub!("\n", "<br/>")
      res['template'] = render_to_string(:partial => '/story_comment')
      res['success'] = true
      res['comment'] = comment
    else
      res = { :success => Story.update_action_on_story(params, user.id) }
    end
    render :json => res.to_json
  end

  def like_dislike_a_comment
    render_404 and return unless user = current_user
    res = Story.update_comment(params, user.id)
    render :json => { :success => res }
  end

  def notify
    story_glimpse = $r.hget("story:#{params[:story_id]}", :text)[0..20] + "..."
    story_details = case params[:action]
    when "like"
      { :act => "liked",
        :glimpse => story_glimpse
      }
    when "comment"
      {
        :act => "commented",
        :glimpse => story_glimpse
      }
    end

    # Notify owner of the new like/comment. Not dislike
    # AccountNotifier.new_notif(user, action, story_details) unless action == :dislike
  end

  def create_new_story
    render_404 and return unless @user = current_user
    new_story_id = Story.add_new_story(params, @user)

    @user.indicate_participation_in(params[:panels])
    Newsfeed.add_story_to_feeds(new_story_id, params[:panels])
    Panel.add_new_story_to(params[:panels], new_story_id)
    
    render :json => {
      :story => render_to_string(:partial => "/story", :locals => { :story => Story.get_stories([new_story_id])[0] } )
    }
  end

  def get_persons_on_story_actions
    base_action = "get_#{params[:t]}"
    res = {}
    if params[:t] == "comments"
      res['template'] = render_to_string(:partial => '/story_comment')
      comments = Story.get_comments(params[:story_id], params[:start].to_i, params[:end].to_i)
      comments.each do |c|
        c['when'] = decorate_redis_time(c['when'])
      end
      res['comments'] = comments
    else
      user_ids = Story.send(base_action, params[:story_id])
      res['persons'] = User.get_display_items_for_modal(user_ids)
    end
    res['success'] = true
    render :json => res.to_json
  end

  def get_more_comments
    Story.get_all_comments(params[:story_id])
  end

  def get_comment_faces
    base_action = "get_#{params[:action]}_on_comment"
    user_ids = Story.send(base_action, params[:story_id], params[:number])
    persons = User.get_display_items_for_modal(user_ids)

    render :json => {
      :success => true,
      :persons => persons
    }
  end

  def show
    render_404 and return unless params[:id]
    @story = Story.get_stories([params[:id]])[0]
    @user = current_user
    render 'one_story'  
  end

end
