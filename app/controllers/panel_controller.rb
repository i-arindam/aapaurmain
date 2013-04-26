class PanelController < ApplicationController

  def show
    @user = current_user
    # render_401 and return unless @user
    @panel = params[:name]
    sids = $r.lrange("panel:#{@panel}:stories", 0, 9)
    @stories = Story.get_stories(sids)
    @page_type = 'panels'
    @users = Panel.get_showable_users(params[:name], @user && @user.id)

    render 'panel/feed_from_panel'
  end

  def show_more_stories
    user = current_user
    render_401 and return unless user
    panel, story_start_num, num_stories = params[:name], params[:start].to_i, params[:num].to_i
    sids = $r.lrange("panel:#{panel}:stories", story_start_num, num_stories)
    stories = Story.get_stories(sids)
    render :json => {
      :success => true,
      :stories => stories
    }
  end

end
