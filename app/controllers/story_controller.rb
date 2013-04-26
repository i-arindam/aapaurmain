class StoryController < ApplicationController

  def like_dislike_or_comment
    get_login_signup and return unless user = current_user
    res = {}
    if params[:work] == "comment"
      comment = Story.add_comment(params, user)
      res['template'] = render_to_string(:partial => '/story_comment')
      res['success'] = true
      res['comment'] = comment
      res['comment']['text'] = ActionController::Base.helpers.auto_link(comment.text, :html => { :target => '_blank' })
    else
      success, likes_reversed = Story.update_action_on_story(params, user.id)
      res = { :success => success, :likes_reversed => likes_reversed }
    end
    render :json => res.to_json
  end

  def like_dislike_a_comment
    render_401 and return unless user = current_user
    success, likes_reversed = Story.update_comment(params, user.id)
    render :json => { :success => success, :likes_reversed => likes_reversed }
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
    StoryPointer.add_new_story_reference(new_story_id, @user.id, params[:panels])
    
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
    render_404 and return if $r.type("story:#{params[:id]}") == "none"
    @story = Story.get_stories([params[:id]])[0]
    @author = User.find_by_id(@story['by_id'])
    @user = current_user
    @page_type = "one_story"

    other_story_ids = StoryPointer.find(:all, :conditions => ["user_id = ? AND story_id != ?", @story['by_id'].to_i, @story['id'].to_i], :order => "id DESC", :limit => 3, :select => "DISTINCT(story_id)").collect(&:story_id)
    @other_stories = Story.get_stories(other_story_ids) unless other_story_ids.blank?
    
    render 'one_story'  
  end

  def delete_story
    render_401 and return unless current_user
    sid = params[:id]
    StoryPointer.delete_story_references(sid.to_i, current_user.id)

    comment_count = $r.llen("story:#{sid}:comments").to_i
    for i in 0..comment_count
      $r.del("story:#{sid}:comments:#{i}:claps", "story:#{sid}:comments:#{i}:boos")
    end
    $r.del("story:#{sid}", "story:#{sid}:panels", "story:#{sid}:claps", "story:#{sid}:boos", "story:#{sid}:comments")
    render :json => { :success => true }
  end

end
