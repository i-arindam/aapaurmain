class UsersController < ApplicationController
  
  ### REQUESTS ACTION STARTS ###
  
  # Creates a request from a user to another user
  # Returns json response of success or failure with the message
  # @param [Fixnum(11)] from_id
  # => id of the user who is creating the request
  # @param [Fixnum(11)] to_id
  # => id of the user to whom the request will be sent
  def create_request
    from_user = User.find_by_id(params[:from_id])
    render_404 and return unless from_user and from_user == current_user
    to_user = User.find_by_id(params[:to_id])
    
    render_404 and return unless to_user
    success = from_user.create_new_request(to_user)
    
    message = (success ? User::REQUEST_SENT : User::REQUEST_FAILED)
    message.gsub!('{{user}}', to_user.name)
    
    render :json => {
      :success => success,
      :message => message
    }
  end
  
  # Accepts a request sent to me from another user
  # @param [Fixnum(11)] to_id 
  # => The id of the user to whom the request was sent, i.e., me. 
  # => This is passed explicitly to thwart non owner based attacks
  # @param [Fixnum(11)] from_id
  # => The id of the user who had sent the request
  def accept_request
    to_user = User.find_by_id(params[:to_id])
    render_404 and return unless to_user and to_user == current_user and to_user.has_active_subscription?
    from_user = User.find_by_id(params[:from_id])
    
    render_404 and return unless from_user
    success = to_user.accept_request_from(from_user)
    
    User.remove_both_users_on_lock(to_user, from_user) if success

    message = (success ? User::REQUEST_ACCEPTED : User::REQUEST_FAILED)
    message.gsub!('{{user}}', to_user.name)
    
    render :json => {
      :success => success,
      :message => message
    }
  end
  
  
  # Withdraws a request from a user to another user
  # Returns json response of success or failure with the message
  # @param [Fixnum(11)] from_id
  # => id of the user who is withdrawing the request
  # @param [Fixnum(11)] to_id
  # => id of the user to whom the request was sent
  def withdraw_request
    from_user = User.find_by_id(params[:from_id])
    render_404 and return unless from_user and from_user == current_user
    to_user = User.find_by_id(params[:to_id])
    
    render_404 and return unless to_user
    
    success = from_user.withdraw_request_to(to_user)
    message = (success ? User::REQUEST_WITHDRAWN : User::REQUEST_FAILED)
    message.gsub!('{{user}}', to_user.name)
    
    render :json => {
      :success => success,
      :message => message
    }
  end
  
  
  # Rejects a request sent to me from another user
  # @param [Fixnum(11)] to_id 
  # => The id of the user to whom the request was sent, i.e., me. 
  # => This is passed explicitly to thwart non owner based attacks
  # @param [Fixnum(11)] from_id
  # => The id of the user who had sent the request
  def decline_request
    to_user = User.find_by_id(params[:to_id])
    render_404 and return unless to_user and to_user == current_user and to_user.has_active_subscription?
    from_user = User.find_by_id(params[:from_id])
    
    render_404 and return unless from_user
    success = to_user.decline_request_from(from_user)
    
    message = (success ? User::REQUEST_DECLINED : User::REQUEST_FAILED)
    message.gsub!('{{user}}', from_user.name)
    
    render :json => {
      :success => success,
      :message => message
    }
    
  end
  
  ### REQUESTS ACTION ENDS ###
  
  ### POST LOCK STATE STARTS ###
  
  # Fired when one Withdraws one of his locks
  # Inactivates the lock and updates the state of the user
  # @param [Fixnum(11)] id
  # => The id of the user who is withdrawing the lock
  # @param [Fixnum(11)] lock_id
  # => The id of the lock being withdrawn
  def withdraw_lock
    withdrawing_user = User.find_by_id(params[:from_id])
    render_404 and return unless withdrawing_user and withdrawing_user == current_user
    
    lock = Lock.find_by_one_id(params[:from_id])
    lock = Lock.find_by_another_id(params[:from_id]) if lock.nil?
    render_404 and return unless lock and lock.is_active? and (lock.one_id == params[:from_id].to_i || lock.another_id == params[:from_id].to_i)
    
    lock.update_withdrawn
    to_user = User.find_by_id(params[:to_id])
    message = (success ? User::REJECT_REQUEST_SENT : User::REJECT_REQUEST_FAILED_TO_SAVE)
    message.gsub!('{{user}}', to_user.name)
    
    render :json => {
      :success => success,
      :message => message
    }
    #withdrawing_user.update_status_post_lock_withdraw
  end
  
  # One of the user in a locked state comes and updates status as successfull Marriage.
  # Notifications and confirmation sent to the other user to verify this.
  # @param [Fixnum(11)] id
  # => The id of the user changing the state
  # @return [JsonObject] denoting the 
  # => success of the request, and
  # => the corresponding message
  def request_confirm_locked
    notifying_user = User.find_by_id(params[:id])
    render_404 and return unless notifying_user and notifying_user == current_user
    
    to_approve_user = User.find_by_id(notifying_user.locked_with)
    render_404 and return unless to_approve_user and to_approve_user.status == User::LOCKED and to_approve_user.locked_with == params[:id]
    
    success = notifying_user.request_mark_as_married
    message = (success ? User::SUCCESS_REQUEST_SENT : User::SUCCESS_REQUEST_FAILED_TO_SAVE)
    message.gsub!('{{user}}', to_approve_user.name)
    
    to_approve_user.send_request_for_successful_lock if success

    render :json => {
      :success => success,
      :message => message
    }
  end
  
  # When one person has notified of the success and the other confirms it
  # Store them as couple and mark their married_date
  # Also creates a new entry in couples table
  # @param [Fixnum(11)] id
  # => The id of the user who confirmed the request
  # @return [JsonObject] denoting the 
  # => success of the request, and
  # => the corresponding message
  def confirm_success
    accepting_user = User.find_by_id(params[:id])
    render_404 and return unless accepting_user and accepting_user == current_user
    
    requesting_user = User.find_by_id(accepting_user.locked_with)
    render_404 and return unless requesting_user and requesting_user.status == User::MARK_MARRIED and requesting_user.locked_with == accepting_user.id
    
    success = User.mark_as_married(requesting_user, accepting_user)
    
    message = (success ? User::SUCCESS_REQUEST_ACCEPTED : User::SUCCESS_REQUEST_FAILED_TO_SAVE)
    message.gsub!('{{user}}', to_approve_user.name)

    render :json => {
      :success => success,
      :message => message
    }
  end
  
  ### POST LOCK STATE STARTS ###
  
  def create
    try_and_create("new")
  end
  
  def new
    @user = User.new
  end
  
  def showme
    if @user = current_user

      @values = {}
      @values['json'] = user_json_object(@user.locked_with) if @user.status == User::LOCKED
      render :dashboard_locked and return if @user.status == User::LOCKED
      
      in_requests_ids = @user.incoming_requests.collect(&:from_id)
      @in_requests = User.find_all_by_id(in_requests_ids)
      @viewer_pane_info = {}
      @viewer_pane_info[:in_requests] = {}
      in_requests_ids.each do |in_req|
        request = Request.find_by_from_id_and_to_id(in_req, @user.id)
        if request
          @viewer_pane_info[:in_requests][in_req] = 
          {
            :show_accept => request.status == Request::ASKED , :show_decline => request.status == Request::ASKED, :show_send => false , :show_withdraw => false , 
            :show_withdraw_lock => request.status == Request::ACCEPTED
          }
        end
      end
      
     
    
      out_requests_ids = @user.outgoing_requests.collect(&:to_id)
      @out_requests = User.find_all_by_id(out_requests_ids)
      @viewer_pane_info[:out_requests] = {}
      out_requests_ids.each do |out_req|
        request = Request.find_by_from_id_and_to_id(@user.id,out_req)
          @viewer_pane_info[:out_requests][out_req] = 
          {
            :show_accept => false , :show_decline => false, :show_send => request.nil? , :show_withdraw => request && request.status == Request::ASKED,
            :show_withdraw_lock => request && request.status == Request::ACCEPTED
          }
      end
      
      @recos = User.find_all_by_id(@user.recommended_user_ids)
      
      profile_viewer_ids = @user.profile_viewers.order("updated_at DESC").limit(20)
      @profile_viewers = profile_viewer_ids.map do |p|
        u = User.find_by_id(p.viewer_id)
        if u
          { :id => p.viewer_id, :name => u.name, :photo => u.photo_url, :viewed_on_date => p.updated_at.strftime("%d %b '%y"), :viewed_on_time => p.updated_at.strftime("%l:%M %P") }
        end
      end
      
      @profile_viewers_users = User.find_all_by_id(profile_viewer_ids.collect(&:viewer_id))
      
      @values['json'] = user_json_object(params[:id])
      render :dashboard
    else
      render :text => "Please login first"
    end
  end
    
  def show
    @values = {}
    render_404 and return unless params[:id]
    @current_user = current_user
    @user = User.find_by_id(params[:id]) 
    render_404 and return unless @user
    
    if @current_user 
      if @current_user.id == params[:id].to_i
        redirect_to :action => :showme and return        
      end

      #Check if the logged in user has sent request to this user. Show buttons accordingly
      request = Request.find_by_from_id_and_to_id(@current_user.id, @user.id)
      @values['show-send'] = true if request.nil?

      if request
         @values['show-chat'] = (request.status == Request::ACCEPTED)
        @values['show-withdraw'] = @current_user && request.status == Request::ASKED
      end
    
      #Check if the logged in user has received request from this user. Show buttons accordingly
      request = Request.find_by_from_id_and_to_id(@user.id, @current_user.id)
      if request
        @values['show-accept'] = @values['show-decline'] = request.status == Request::ASKED if @current_user.id == params[:id].to_i
      end
      

      # Log profile views
      view = @user.profile_viewers.where(:viewer_id => @current_user.id)
      unless view.blank?
        # To update the latest time
        view[0].touch
      else
        view = @user.profile_viewers.create({ :viewer_id => @current_user.id })
      end
      
    else # Not logged in user
      @values['show-chat'] = false
      @values['show-send'] = true
      @values['show-cta'] = true
    end
    
    @values['json'] = user_json_object(params[:id])
    render :profile
  end
  
  def show_viewers
    user = User.find_by_id(params[:id])
    render_404 and return unless @current_user = current_user and @current_user == user
    @viewers = @current_user.profile_viewers
  end
  
  
  def signup
    params[:user] = {
      :email => params[:email],
      :password => params[:password],
      :password_confirmation => params[:password_confirmation]
    }
    
    try_and_create("static_pages/home")
  end
  
  def try_and_create(failure_render_path)
    @user = User.new(params[:user])
    if @user.save
      cookies[:auth_token] = @user.auth_token
      redirect_to "/users/#{@user.id}/create_profile", :notice => "Sign Up Successful!" and return
    else
      render "#{failure_render_path}"
    end
  end
  
  def create_profile
    @user = User.find_by_id(params[:id])
  end
  
  def update
    @user = User.find_by_id(params[:id])
    uhash = params[:user]
    success, message = true, ""
    
    valid_date = verify_dob(uhash[:dob])
    redirect_to :back, :alert => "Invalid Dob" and return unless valid_date
    
    dob = get_date(uhash[:dob])
    sex = uhash[:sex]
    valid_age = verify_age(dob, sex)
    
    redirect_to :back, :alert => "Invalid age for #{sex}s. Must be above " + (sex == "male" ? 21 : 18).to_s + " years" and return unless valid_age
    
    fields = User::USER_FIELDS_LIST
    fields.each do |f|
      @user[f.to_s] = uhash[f] if uhash[f]
    end

    hobbies = params[:user][:hobby]
    
    unless hobbies.blank?
      hobbies.each do |h|
        uh = Hobby.new
        uh.user_id = @user.id
        uh.hobby = h
        uh.save
      end
    end

    interested = params[:user][:interest]
    unless interested.blank?
      interested.each do |i|
        ui = InterestedIn.new
        ui.user_id = @user.id
        ui.interested = i
        ui.save
      end
    end
    
    @user.setup_recos_on_create
    
    @user.save
    
    redirect_to "/users/showme"
  end
  
  def more_info
    @user = User.find_by_id(params[:id])
    render_404 and return unless @user
    
    respond_to do |format|
      format.json{render :json=>{}}
      format.html{render(:locals => { :user => @user} ,:layout=>false)}
    end
    
  end
  
  def check_request_exists(to_user_id)
    
  end
  
  def user_json_object(to_id=nil)
    require 'json'
    json_obj = {
      :to_user_id => to_id.to_i,
      :session_user_id => (current_user && current_user.id),
      :name => (current_user && current_user.name)
    }
    json_obj.to_json
  end
  
  
  
  def upload_photo
    session_user = current_user

    img = params[:qqfile].is_a?(String) ? request.body : params[:qqfile]
    img.rewind
    errors = {
      :invalid_format => 'Unsupported image format',
      :size_limit_exceeded => 'Image upload failed. Maximum allowed size is 4MB'
    }

    unless is_file_object(img) and is_image?(img)
      render :text => {:success => false, :message => errors[:invalid_format]}.to_json and return
    end
    unless img.size <= 4194304
      render :text => {:success => false, :message => errors[:size_limit_exceeded]}.to_json and return
    end
    session_user.photo_url = img
    render :text => {:success => true }.to_json
  end
  


   # Handles the ajax 'delete' request from 'My Photo' page
   def delete_photo
       session_user = current_user
     begin
       session_user.delete_photo      
       render :json => { :success => true }
     rescue Exception => e
       logger.error e.backtrace.join("\n")
       render :json => { :success => false, :message => 'Deleting failed. Please try again.' }
     end
   end
  
end
