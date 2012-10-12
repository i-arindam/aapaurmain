class ConversationController < ApplicationController
  
  def conversations
    render_404 and return unless current_user
    my_id = current_user.id
    conversations = Conversation.where("from_user_id = ? OR to_user_id = ? ", my_id, my_id).order("updated_at DESC").uniq
    
    @values = conversations.map do |conv|
      with_user_id = (conv.from_user_id == my_id ? conv.to_user_id : conv.from_user_id)
      with_user = User.find_by_id(with_user_id)
      next unless with_user
      with_user_name = with_user.name
      snippet = conv.messages != [] ? conv.messages.last.text.truncate(95, :omission => "... ") : ""
      
      { :with => with_user_name, :snippet => snippet, :last_time => conv.updated_at.strftime("%d %b '%y"), :id => conv.id }
    end # end conversations.map
  end # End conversations
  
  def show
    @current_user = current_user
    render_404 and return unless @current_user
    @conversation = Conversation.find_by_id(params[:id])
    render_404 and return unless @conversation
    
    @messages = @conversation.messages.order("created_at ASC")
    
    with_user_id = (@conversation.from_user_id == @current_user.id ? @conversation.to_user_id : @conversation.from_user_id)
    @with_user = User.find_by_id(with_user_id)
  end # End show
  
  def new_message
    @current_user = current_user
    render_404 and return if params[:id].nil? or !@current_user
    @conversation = Conversation.find_by_id(params[:id])
    render_404 and return unless @conversation

    comment_text = params[:message][:text]
    to_user_id = (@conversation.from_user_id == @current_user.id ? @conversation.to_user_id : @conversation.from_user_id)
    message = @conversation.messages.create({
      :text => comment_text,
      :from => @current_user.id,
      :to => to_user_id
    })
    
    if message
      render :json => {
        :status => true,
        :name => @current_user.name,
        :time => message.created_at.strftime("%l:%M %P"),
        :date => message.created_at.strftime("%d %b '%y"),
        :text => comment_text
      }
    else
      render :json => {
        :status => false,
        :message => "Message failed to create"
      }
    end
  end # End new_message

  def conversation_with
  end
  
end
