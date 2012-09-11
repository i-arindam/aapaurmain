class ChatController < ApplicationController
  require "pusher"

  def create
    Pusher['presence-demo'].trigger('message', {
          :user_id => current_user.id,
          :text => params[:text]
        })
     return
  end
  
  def auth
    # There's only one channel in this simple demo so we can hard code it
    #raise "Unknown channel" unless params[:channel_name] == 'presence-demo'
    channel_name = params[:channel_name]
    participant_list = channel_name.split("-")
    this_user_id = participant_list[1]
    that_user_id = participant_list[2]
    this_user = current_user

    can_chat = this_user.can_chat(that_user_id)
    render :text => "Not authorized", :status => '403' and return unless can_chat
    
    channel = Pusher[channel_name]

    if this_user
      response = channel.authenticate(params[:socket_id], {
        :user_id => current_user.id,
        :user_info => {
          :gravatar => current_user.name
        }
      })
      render :json => response
    else
       render :text => "Not authorized", :status => '403'
    end
  end
  
  
  
end
