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
    render_404 and return unless from_user and from_user == session[:user]
    to_user = User.find_by_id(params[:to_id])
    
    render_404 and return unless to_user
    success = from_user.create_new_request(to_user)
    
    message = (success ? User::REQUEST_SENT : User::REQUEST_FAILED)
    
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
    render_404 and return unless to_user and to_user == session[:user] and to_user.has_active_subscription?
    from_user = User.find_by_id(params[:from_id])
    
    render_404 and return unless from_user
    success = to_user.accept_request_from(from_user)
    message = (success ? User::REQUEST_ACCEPTED : User::REQUEST_FAILED)
    
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
    render_404 and return unless to_user and to_user == session[:user] and to_user.has_active_subscription?
    from_user = User.find_by_id(params[:from_id])
    
    render_404 and return unless from_user
    
    to_user.decline_request_from(from_user)
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
    withdrawing_user = User.find_by_id(params[:id])
    render_404 and return unless withdrawing_user and withdrawing_user == session[:user]
    
    lock = Lock.find_by_id(params[:lock_id])
    render_404 and return unless lock and lock.is_active? and (lock.one_id == params[:id] || lock.another_id == params[:id])
    
    lock.update_withdrawn
    withdrawing_user.update_status_post_lock_withdraw
  end
  
  def finalize_lock
    
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
    render_404 and return unless notifying_user and notifying_user == session[:user]
    
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
    render_404 and return unless accepting_user and accepting_user == session[:user]
    
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
  
  # Fired when someone in the lock indicates a rejection
  # The other person is sent a notification for approval
  # @param [Fixnum(11)] id
  # => The id of the person who requested the reject
  # @return [JsonObject] denoting the 
  # => success of the request, and
  # => the corresponding message
  def request_reject_locked
    rejecting_user = User.find_by_id(params[:id])
    render_404 and return unless rejecting_user and rejecting_user.status == User::LOCKED and rejecting_user == session[:user]
    
    to_approve_user = User.find_by_id(rejecting_user.locked_with)
    render_404 and return unless to_approve_user and to_approve_user.status == User::LOCKED and to_approve_user.locked_with = params[:id]
    
    success = rejecting_user.request_mark_as_rejected
    message = (success ? User::REQUEST_REJECT_SENT : User::REQUEST_REJECT_FAILED_TO_SAVE)
    message.gsub!('{{user}}', to_approve_user.name)
    
    to_approve_user.send_request_for_confirming_reject if success
    
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
  
  def show
    
    if params[:who] == "me"      
      #@todo : debug line. remove later
      session[:user] = User.first
      
      if session[:user]  
        @user = User.find(:first, :conditions => ['id = ?', session[:user_id]]) || User.first
        in_requests_objects = @user.incoming_requests                                 
        in_requests_ids = in_requests_objects.collect(&:from_id)
        
 
        @in_requests = User.find( :all,
                                  :conditions => "id in (#{in_requests_ids * "," })",
                                  :select => "name") rescue nil # @todo add photo_url
        
        out_requests_objects = @user.outgoing_requests
        out_requests_ids = out_requests_objects.collect(&:to_id)
        
        @out_requests = User.find( :all,
                                  :conditions => "id in (#{out_requests_ids * "," })",
                                  :select => "name" ) rescue nil # @todo add photo_url
        
        render :dashboard
      else
        render :text => "Please login first"
      end
    else
      render :text=> "Missing params[:id]" and return unless params[:id]
      @user = User.find_by_id(params[:id]) 
      render_404 and return unless @user
      render :profile
    end
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
      redirect_to "/users/#{@user.id}/create_profile", :notice => "Sign Up Successful!" and return
    else
      render "#{failure_render_path}"
    end
  end
  
  def create_profile
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
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
    
    @user.save
    
    render :dashboard
  end
  
end