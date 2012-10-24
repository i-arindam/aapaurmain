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

    r = Request.find_by_from_id_and_to_id(from_user.id,to_user.id)
    if r.nil?
      success = from_user.create_new_request(to_user) 
      message = (success ? User::REQUEST_SENT : User::REQUEST_FAILED)
    elsif r.status == Request::DECLINED
      success = false
      message = User::REQUEST_NOT_SENT
    elsif r.status == Request::WITHDRAWN      
      success = Request.set_as_asked(to_user.id,from_user.id)
      message = (success ? User::REQUEST_SENT : User::REQUEST_FAILED)
    end 

    m=message.gsub('{{user}}', to_user.name)
    
    render :json => {
      :success => success,
      :message => m
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
    m=message.gsub!('{{user}}', to_user.name)
    
    render :json => {
      :success => success,
      :message => m
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
    m = message.gsub('{{user}}', to_user.name)
    
    render :json => {
      :success => success,
      :message => m
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
    m=message.gsub('{{user}}', from_user.name)
    
    render :json => {
      :success => success,
      :message => m
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
   
    
    withdrawing_user.update_status_post_lock_withdraw
    to_user.update_status_post_lock_withdraw
    withdrawing_user.decline_request_from(to_user)
    success = to_user.decline_request_from(withdrawing_user)
    
    message = (success ? User::REJECT_REQUEST_SENT : User::REJECT_REQUEST_FAILED_TO_SAVE)
    m=message.gsub('{{user}}', to_user.name)

    render :json => {
      :success => success,
      :message => m
    }
    
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
    m=message.gsub('{{user}}', to_approve_user.name)
    
    to_approve_user.send_request_for_successful_lock if success

    render :json => {
      :success => success,
      :message => m
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
    m=message.gsub('{{user}}', to_approve_user.name)

    render :json => {
      :success => success,
      :message => m
    }
  end
  
  ### POST LOCK STATE STARTS ###
  
  def create
    try_and_create("new")
  end
  
  def new
    @user = User.new
  end

  # def show_my_profile
  #   redirect_to (:action => 'show', :parmams => {:dashboard => false}) 
  # end
  
  def showme
    
    if @user = current_user

      @values = {}
      @values['json'] = user_json_object(@user.locked_with) if @user.status == User::LOCKED
      
      # Changing behaviour if user is locked, show him the mentioned template
      # That page is significantly different from the normal view.
      if @user.status == User::LOCKED
        @with_user = User.find_by_id(@user.locked_with)
        random_index = gimme_random_value($user_tips['locked_tips'].length)
        @tip = $user_tips['locked_tips'][random_index]
 
        # Need to check if this user is a from or to user
        @conversation = Conversation.find_by_from_user_id_and_to_user_id(@user.id, @user.locked_with) || Conversation.find_by_to_user_id_and_from_user_id(@user.id, @user.locked_with)
        
        # If they haven't talked, create the conversation here.
        unless @conversation
          @conversation = Conversation.create({
              :from_user_id => @user.id,
              :to_user_id => @user.locked_with,
            })
          @messages = []
        else
          @messages = @conversation.messages.order("created_at ASC")
        end
 
        render :dashboard_locked and return
      end
      
      in_requests_ids = @user.incoming_requests.collect(&:from_id)
      @in_requests = User.find_all_by_id(in_requests_ids)

      @tab_to_show = 'in' unless @in_requests.blank?

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

      @tab_to_show = 'out' unless @out_requests.blank? or defined?(@tab_to_show)

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

      
      @recos = get_default_recos if @recos.length < 3

      @tab_to_show = 'reco'
      
      profile_viewer_ids = @user.profile_viewers.order("updated_at DESC").limit(20)
      @profile_viewers = profile_viewer_ids.map do |p|
        u = User.find_by_id(p.viewer_id)
        if u
          { :id => p.viewer_id, :name => u.name, :photo => u.photo_url, :viewed_on_date => p.updated_at.strftime("%d %b '%y"), :viewed_on_time => p.updated_at.strftime("%l:%M %P") }
        end
      end
      
      @profile_viewers_users = User.find_all_by_id(profile_viewer_ids.collect(&:viewer_id))
      
      @values['json'] = user_json_object()
      render :dashboard
    else
      render :text => "Please login first"
    end
  end
    
  def show
    
    render_404 and return unless current_user
    @values = {}
    render_404 and return unless params[:id]
    @current_user = current_user
    @user = User.find_by_id(params[:id]) 
    render_404 and return unless @user
    
    if @current_user.id != params[:id].to_i     # View other user's profile
      #Check if the logged in user has sent request to this user. Show buttons accordingly
      sent_request = Request.find_by_from_id_and_to_id(@current_user.id, @user.id)
      @values['show-send'] = true if sent_request.nil? 

      if sent_request
        @values['show-withdraw'] =  true if sent_request.status == Request::ASKED   
        @values['show-send'] =  false if sent_request.status == Request::DECLINED  
      end
    
      #Check if the logged in user has received request from this user. Show buttons accordingly
      received_request = Request.find_by_from_id_and_to_id(@user.id, @current_user.id)
      if received_request 
        @values['show-accept'] = @values['show-decline'] =  (received_request.status == Request::ASKED)  
        @values['show-send'] =  false  
      end
      
      if (sent_request and sent_request.status == Request::ACCEPTED) or (received_request and received_request.status == Request::ACCEPTED)
         @values['show-chat'] = @values['show-withdraw-lock'] = true
         @values['show-send'] = @values['show-accept'] = @values['show-withdraw'] = false
      end

      # Log profile views
      view = @user.profile_viewers.where(:viewer_id => @current_user.id)
      unless view.blank?
        # To update the latest time
        view[0].touch
      else
        view = @user.profile_viewers.create({ :viewer_id => @current_user.id })
      end
      
    else # Show my own profile
      @values['show-chat'] = false
      @values['show-send'] = @values['show-accept'] = @values['show-withdraw'] = @values['show-withdraw-lock'] = false 
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
      :name => params[:name],
      :email => params[:email],
      :password => params[:password],
      :password_confirmation => params[:password_confirmation]
    }
    
    try_and_create("static_pages/home")
  end
  
  def try_and_create(failure_render_path)
    user = User.new(params[:user])
    if user.save
      
      send_confirmation_link user
      flash[:success] = "A confirmation link has been sent to your email. Please check your email and click on the link to verify your account"
      render "static_pages/message"
    else
      render "#{failure_render_path}"
    end
  end

  def send_confirmation_link(user)

    confirmation_link = get_confirmation_key(user)
    mail_params = {
      :mail_options => {:to => user.email, :subject => "Please confirm your account with aapaurmain", :template => 'email_confirm', :url => confirmation_link},
      :url => confirmation_link
    }
    UserMailer.send_signup_confirmation mail_params
  end

  def get_confirmation_key(user)
    hash = {
      :id => user.id,
      :email => user.email
    }

    json_hash = hash.to_json
    confirmation_key = Base64.encode64 json_hash
    url_for :controller => 'users', :action => 'confirm_signup', :key => URI.escape(confirmation_key)
  end

  def confirm_signup
    
    key = params[:key]
    user_hash = get_user_hash_from_signup_confirm_key key
    user = User.find_by_id user_hash["id"]

    if user.blank?
      render_404
    end
    if user.signup_confirmed?
      flash[:success] = "Your account is already confirmed. Please login to continue."
      render "static_pages/message"
    elsif user.email == user_hash["email"]
      user.confirm_signup
      
      flash[:success] = "Your account is confirmed. Please login to continue"
      render "static_pages/message"
    end
  end

  def get_user_hash_from_signup_confirm_key(key)
    
    unescaped_key = URI.unescape key
    json_hash = Base64.decode64 unescaped_key
    hash = JSON.parse json_hash
  end
  
  def create_profile
    @user = User.find_by_id(params[:id])
    # render_404 and return unless @user == current_user
  end

  def edit_profile
    @user = User.find_by_id(params[:id])
    render_404 and return unless @user == current_user
    render :create_profile
  end
  
  def update
    @user = User.find_by_id(params[:id])
    render_404 and return unless @user == current_user
    uhash = params[:user]
    success, message = true, ""
    
    dob = uhash[:dob]
    sex = uhash[:sex]
    valid_age = verify_age(dob, sex)
    
    redirect_to :back, :alert => "Invalid age for #{sex}s. Must be above " + (sex == "male" ? 21 : 18).to_s + " years" and return unless valid_age
    
    @user.dob = dob
    @user.siblings = uhash[:siblings].to_i rescue nil
    fields = User::USER_FIELDS_LIST
    fields.each do |f|
      @user[f.to_s] = uhash[f] if uhash[f]
    end

    hobbies = (params[:user][:hobby]).split(",")
    # old_hobbies = @user.hobby.map(&:hobby)
    # changed_hobbies = hobbies-old_hobbies

    #ugly hack for updating values
    @user.hobby.destroy_all
    @user.interested_in.destroy_all
    @user.not_interested_in.destroy_all
    
    unless hobbies.blank?
      hobbies.each do |h|
        uh = Hobby.new
        uh.user_id = @user.id
        uh.hobby = h
        uh.save
      end
    end

    interested = (params[:user][:interest]).split(",")
    unless interested.blank?
      interested.each do |i|
        ui = InterestedIn.new
        ui.user_id = @user.id
        ui.interested = i
        ui.save
      end
    end

    not_interested = (params[:user][:not_interest]).split(",")
    unless not_interested.blank?
      not_interested.each do |i|
        ni = NotInterestedIn.new
        ni.user_id = @user.id
        ni.not_interested = i
        ni.save
      end
    end
    

    @user.setup_recos_on_create unless Rails.env == 'development'
    @user.add_to_search_index unless Rails.env == 'development'

    @user.save
    
    redirect_to "/users/#{@user.id}"
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
      :name => (current_user && current_user.name),
      :send_request_text => $aapaurmain_conf['modal-dialog-messages']['send-request'],
      :accept_request_text => $aapaurmain_conf['modal-dialog-messages']['accept-request'],
      :decline_request_text => $aapaurmain_conf['modal-dialog-messages']['decline-request'],
      :withdraw_request_text => $aapaurmain_conf['modal-dialog-messages']['withdraw-request'],
      :withdraw_lock_text => $aapaurmain_conf['modal-dialog-messages']['withdraw_lock']
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

  # Living off with default recos to begin with
  def get_default_recos
    if @user.sex == 'male'
      return User.find_all_by_id([5, 8, 10, 11, 12, 15, 17])
    else
      return User.find_all_by_id([1, 2, 3, 4, 6, 7, 13])
    end
  end

end
