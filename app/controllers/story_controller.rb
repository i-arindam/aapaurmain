class StoryController < ApplicationController

  def like_dislike_or_comment
    render_404 and return unless user = current_user
    Story.update_action_on_story(params, user)
  end

  def like_dislike_a_comment
    render_404 and return unless user = current_user
    Story.update_comment(params, user)
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
    Newsfeed.add_story_to_feed(new_story_id, params[:board])
  end

  def get_interactions_on_story
    base_action = "get_#{params[:action]}"
    Story.send(base_action, params[:story_id])
  end

  def get_more_comments
    Story.get_all_comments(params[:story_id])
  end

  def get_comment_faces
    base_action = "get_#{params[:action]_on_comment}"
    res = Story.send(base_action, params[:story_id], params[:number])
    res.map do |r|
      r.merge!(:photo => User.find_by_id(r['by_id']).photo_url)
    end.to_json
  end

end
