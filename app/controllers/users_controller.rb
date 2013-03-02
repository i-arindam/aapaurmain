class UsersController < ApplicationController
  
  ### REQUESTS ACTION STARTS ###
  
  # Creates a request from a user to another user
  # Returns json response of success or failure with the message
  # @param [Fixnum(11)] from_id
  # => id of the user who is creating the request
  # @param [Fixnum(11)] to_id
  # => id of the user to whom the request will be sent
  def create_request
    from_user = current_user
    render_404 and return unless from_user
    to_user = User.find_by_id(params[:user_id])
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
    render_401 and return unless current_user
    req = Request.find_by_id(params[:id])
    render_404 and return unless req
    from_user = User.find_by_id(req.from_id)
    render_404 and return unless from_user

    success = current_user.accept_request_from(from_user)
    message = (success ? User::REQUEST_ACCEPTED : User::REQUEST_FAILED)
    message.gsub!('{{user}}', from_user.name)
    
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
    render_401 and return unless current_user
    req = Request.find_by_id(params[:id])
    render_404 and return unless req
    to_user = User.find_by_id(req.to_id)
    render_404 and return unless to_user

    success = current_user.withdraw_request_to(to_user)
    message = (success ? User::REQUEST_WITHDRAWN : User::REQUEST_FAILED)
    message!.gsub('{{user}}', to_user.name)
    
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
    render_401 and return unless current_user
    req = Request.find_by_id(params[:id])
    render_404 and return unless req
    from_user = User.find_by_id(req.from_id)
    render_404 and return unless from_user

    success = current_user.decline_request_from(from_user)
    
    message = (success ? User::REQUEST_DECLINED : User::REQUEST_FAILED)
    message!.gsub('{{user}}', from_user.name)
    
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
    
  def show
    render_401 and return unless @current_user = current_user
    @values = {}
    render_404 and return unless params[:id]
    @user = User.find_by_id(params[:id]) 
    render_404 and return unless @user
    
    #Check if the logged in user has sent request to this user. Show buttons accordingly
    @request = Request.get_request_values(@current_user.id, @user.id)
    # # Log profile views
    # view = @user.profile_viewers.where(:viewer_id => @current_user.id)
    # unless view.blank?
    #   # To update the latest time
    #   view[0].touch
    # else
    #   view = @user.profile_viewers.create({ :viewer_id => @current_user.id })
    # end

    # Panels object
    common_panels, remaining_panels = Panel.get_common_and_other_panels_for(@user.id, @current_user.id)
    @panels = { :common_panels => common_panels, :remaining_panels => remaining_panels}

    # Questions object
    @questions = ShortQuestion.get_latest_n_answers_for(@user.id, 2, 0)

    # Stories object
    @stories = Story.get_n_stories_for(@user.id, 10, 0)

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
      cookies[:auth_token] = user.auth_token
      
      send_confirmation_link user
      flash[:success] = "A confirmation link has been sent to your email. Please check your email and click on the link to verify your account"
      redirect_to "/edit_profile"
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
  
  def edit_profile
    @user = current_user
    render_404 and return unless @user
  end
  
  def update
    @user = current_user
    render_404 and return unless @user
    uhash = params[:user]
    success, message = true, ""
    
    dob = uhash[:dob]
    sex = uhash[:sex]
    valid_age = verify_age(dob, sex)
    
    redirect_to :back, :alert => "Invalid age for #{sex}s. Must be above " + (sex == "male" ? 21 : 18).to_s + " years" and return unless valid_age
    
    @user.update_attributes(uhash)

    @user.save
    redirect_to "/home"
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
      :invalid_format => 'Image upload failed. Please use a valid image format.',
      :size_limit_exceeded => 'Image upload failed. Maximum allowed size is 4MB.'
    }

    unless is_file_object(img) and is_image?(img)
      render :text => {:success => false, :message => errors[:invalid_format]}.to_json and return
    end
    unless img.size <= 4194304
      render :text => {:success => false, :message => errors[:size_limit_exceeded]}.to_json and return
    end
    session_user.photo_url = img
    render :text => {:success => true , :url => original_pic_url(session_user.id) }.to_json
  end
  


   # Handles the ajax 'delete' request from 'My Photo' page
   def delete_photo
     session_user = current_user
     begin
      session_user.photo_exists =false
      session_user.save!
      session_user.delete_photo      
      render :json => { :success => true , :url => original_pic_url(session_user.id) }
     rescue Exception => e
       logger.error e.backtrace.join("\n")
       render :json => { :success => false, :message => 'Deleting failed. Please try again.' }
     end
   end

  # Living off with default recos to begin with
  def get_default_recos
    if @user.sex == 'female'
      return User.find_all_by_id([5, 8, 10, 11, 12, 15, 17])
    else
      return User.find_all_by_id([1, 2, 3, 4, 6, 7, 13])
    end
  end

  def home
    @user = current_user
    render :dashboard
  end

  def my_panels
    @user = current_user
    render_401 and return unless @user
    @panels = @user.get_panels
  end

  def show_requests
    @user = current_user
    render_401 and return unless @user
    direction = params[:direction]

    @title, base_method, user_id = if direction == 'in'
      ["Requests for you", :requests_sent_to_me, 'from_id']
    else
      ["Requests for you", :requests_sent_by_me, 'to_id']
    end

    reqs = Request.send(base_method, @user.id)

    @objects = [] #get_users_and_requests_object()
    @user_ids = []
    reqs.each do |r|
      @objects.push({
        :user => User.find_by_id(r[user_id]),
        :request => r.get_for_display(direction)
      })
      @user_ids.push(r[user_id])
    end
    @has_data = @user_ids.length > 0
    @next_steps = render_to_string(:partial => "users/next_steps_requests_#{direction}")

    render :show_people
  end

  def people_i_follow
    @user = current_user
    render_401 and return unless @user
    @title = 'People you like'
    @user_ids = @user.user_follows.collect(&:following_user_id)
    users = User.find_all_by_id(@user_ids)
    @has_data = users.length > 0
    @objects = get_display_for_list_page(users, @user)
    @next_steps = render_to_string(:partial => "users/next_steps_my_followings")

    render :show_people
  end

  def people_follow_me
    @user = current_user
    render_401 and return unless @user
    @title = 'People who like you'
    @user_ids = UserFollow.find_all_by_following_user_id(@user.id).collect(&:user_id)
    users = User.find_all_by_id(@user_ids)
    @has_data = users.length > 0    
    @objects = get_display_for_list_page(users, @user)
    @next_steps = render_to_string(:partial => "users/next_steps_my_followers")

    render :show_people
  end

  def my_top_stories

  end

  # Ajax endpoints
  def follow_user
    user = current_user
    render_401 and return unless user
    following_user = User.find_by_id(params[:id])
    render_404 and return unless following_user

    follow = user.user_follows.create(:following_user_id => params[:id].to_i)
    render :json => {
      :success => !! follow
    }
  end

  def unfollow_user
    user = current_user
    render_401 and return unless user
    unfollowing_user = User.find_by_id(params[:id])
    render_404 and return unless unfollowing_user

    follow_record = user.user_follows.where(:following_user_id => params[:id])
    follow_record.destroy
    render :json => { :success => true }
  end

  def rate_profile
    user = current_user
    render_401 and return unless user
    rating_profile = User.find_by_id(params[:id])
    render_404 and return unless rating_profile

    rated = ProfileRating.find_or_create_by_my_id_and_user_id(user.id, params[:id].to_i)
    rated.rating = params[:star]
    rated.save
    render :json => { :success => true }
  end

  def get_all_panels_info
    user = User.find_by_id(params[:id])
    render_404 and return unless (user and user == current_user)
    other_user = User.find_by_id(params[:for_user_id])
    common_panels, remaining_panels = Panel.get_common_and_other_panels_for(other_user.id, user.id)

    render :json => {
      :commonPanels => common_panels,
      :remainingPanels => remaining_panels
    }
  end

  def get_top_stories
    user = current_user
    render_401 and return unless user
    desired_user = User.find_by_id(params[:for_user_id])
    render_404 and return unless desired_user
    get_top_stories_for(desired_user.id)
  end

  # If top story ids are not already in redis, compute it here and insert
  # else use it. Redis gets updated with background job every few hours. @todo.
  def get_top_stories_for(desired_user_id, render_template = nil)
    story_ids = $r.lrange("user:#{desired_user_id}:popular_stories", 0, -1)
    if story_ids.nil?
      stories_of_desired_user = $r.lrange("user:#{desired_user_id}:story_ids", 0, -1)
      if stories_of_desired_user.nil?
        top_stories = {
          :success => true,
          :stories => nil
        }
        render :json => top_stories and return
      end

      popularity_hash = {}
      $r.multi do
        stories_of_desired_user.each do |st_id|
          comments_count, claps_count = $r.llen("story:#{st_id}:comments").value, $r.llen("story:#{st_id}:claps").value
          a, b = [comments_count, claps_count].max, [comments_count, claps_count].min
          story_popularity = ( a * 2 + b ) / ( a + b )
          popularity_hash[st_id] = story_popularity
        end
      end

      # Next op will give a 2d array : [ [k,v], [k,v], [k,v] ] where the v's are in descending order
      array_in_descending_order = popularity_hash.sort_by { |k, v| v }.reverse!

      # This one is taken from SO. Pure blindness I say
      story_ids = Hash[*array_in_descending_order.flatten].keys[0..1]
      $r.rpush("user:#{desired_user.id}:popular_stories", story_ids)
    end
    @stories = Story.get_stories(story_ids)
    respond_to do |format|
      format.html { render render_template and return } 
      format.json { render :json => {
        :success => true,
        :stories => @stories
      } and return }
    end
  end

  def get_all_stories
    user = current_user
    render_401 and return unless user
    desired_user = User.find_by_id(params[:for_user_id])
    render_404 and return unless desired_user

    stories = Story.get_n_stories_for(desired_user.id, 10, 0)
    render :json => {
      :success => true,
      :stories => stories
    }
  end

  def get_more_stories
    user = current_user
    render_401 and return unless user
    desired_user = User.find_by_id(params[:for_user_id])
    render_404 and return unless desired_user

    stories = Story.get_n_stories_for(desired_user.id, 10, params[:start].to_i)
    render :json => {
      :success => true,
      :stories => stories
    }
  end

  def get_all_dom_partials
    render :json => {
      :story_partial => render_to_string(:partial => "/story"),
      :question_partial => render_to_string(:partial => "/questions"),
      :panel_partial => render_to_string(:partial => "/panels"),
      :panels => $priorities_list['priorities']
    }
  end

  def my_dashboard
    @user = current_user
    render_401 and return unless @user

    @stories = Newsfeed.get_initial_feed_for(@user.id)
    @questions = ShortQuestion.get_latest_question_for(@user.id)
  end

end
