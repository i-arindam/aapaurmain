#################################################################################
# This class represents users
#
# @attr [Fixnum(11)] id
# @attr [String(50)] name
# @attr [Date] dob
# @attr [String] sex
# @attr [Fixnum(6)] family_preference
# @attr [Float] height
# @attr [Fixnum(6)] spouse_preference
# @attr [Fixnum(20)] spouse_salary
# @attr [String(500)] further_education_plans
# @attr [String(500)] spouse_further_education
# @attr [String(500)] settle_else
# @attr [Fixnum(6)] sexual_preference
# @attr [String(500)] virginity_opinion
# @attr [String(500)] ideal_marriage
# @attr [Fixnum(20)] salary
# @attr [String(500)] hobbies
# @attr [Fixnum(6)] siblings
# @attr [Fixnum(6)] profession
# @attr [String(500)] dream_for_future
# @attr [String(500)] interested_in
# @attr [String(500)] not_interested_in
# @attr [String(255)] settled_in
# @attr [true, false] dont_search
# @attr [Date] hidden_since
# @attr [DateTime] created_at
# @attr [DateTime] updated_at
#
#################################################################################
class User < ActiveRecord::Base
  
  attr_accessible :email, :password, :password_confirmation
 # attr_accessor :password
  has_secure_password
  
  validates :password, :presence => true, :on => :create
  validates :email, :presence => true, :uniqueness => true
  
  before_create { generate_token(:auth_token) }

  DOESNT_MATTER = 10
    
  # Enumeration for family preference
  FAMPREF_NUCLEAR = 1
  FAMPREF_JOINT = 2
  FAMPREF_EXTENDED = 3
  
  # Enumeration for spouse preference
  SPOPREF_WORKING = 1
  SPOPREF_HOMEMAKER = 2
  
  # Enumeration for sexual preference
  SEXPREF_STRAIGHT = 1
  SEXPREF_HOMO = 2
  SEXPREF_BI = 3
  
  # Enumeration for spouse further education
  DONT_WANT = 1
  DEPENDS = 2
  
  # Enumeration for settle elsewhere
  STAY = 1
  CAN_TRY = 2

  
  # Enumeration for sex
  MALE = 0
  FEMALE = 1
  
  # Enumeration for availability `status`
  AVAILABLE = 0
  LOCKED = 1
  MARK_MARRIED = 2
  MARRIED = 3
  
  # Enumeration for requests sending, accepting etc
  REQUEST_SENT = $aapaurmain_conf['requests-message']['sent']
  REQUEST_ACCEPTED = $aapaurmain_conf['requests-message']['accepted']
  REQUEST_DECLINED = $aapaurmain_conf['requests-message']['declined']
  REQUEST_FAILED = $aapaurmain_conf['requests-message']['failed']
  
  # Enumeration for success/reject message in locked state
  SUCCESS_REQUEST_SENT = $aapaurmain_conf['locked-message']['success-sent']
  SUCCESS_REQUEST_ACCEPTED = $aapaurmain_conf['locked-message']['success-accepted']
  SUCCESS_REQUEST_FAILED_TO_SAVE = $aapaurmain_conf['locked-message']['success-failed']
  REJECT_REQUEST_SENT = $aapaurmain_conf['locked-message']['reject-sent']
  REJECT_REQUEST_ACCEPTED = $aapaurmain_conf['locked-message']['reject-accepted']
  REJECT_REQUEST_FAILED_TO_SAVE = $aapaurmain_conf['locked-message']['reject-failed']
  
  # Enumeration for contacting templates
  CONTACT_TEMPLATES = {
    :confirm_locked_success => { :mail => 'confirm_locked_success', :sms => 'confirm_locked_success', :notif => 'confirm_locked_success' },
    :request_sent => { :mail => 'request_sent', :sms => 'request_sent', :notif => 'request_sent' },
    :request_accepted => { :mail => 'request_accepted', :sms => 'request_accepted', :notif => 'request_accepted' },
    :request_declined => { :mail => 'request_declined', :sms => 'request_declined', :notif => 'request_declined' },
    :request_withdrawn => { :operation => 'remove_request' },
    :blocked_state => { :mail => 'request_accepted', :sms => 'request_accepted', :notif => 'request_accepted' },
    :request_for_successful_lock => { :mail => 'request_for_successful_lock', :sms => 'request_for_successful_lock', :notif => 'request_for_successful_lock' },
    :confirm_reject => { :mail => 'confirm_reject', :sms => 'confirm_reject', :notif => 'confirm_reject' }
  }
  
  USER_FIELDS_LIST = [
      :name, :dob, :sex, :family_preference, :height, :spouse_preference,
      :spouse_salary, :further_education_plans, :spouse_further_education,
      :settle_else, :sexual_preference, :virginity_opinion, :ideal_marriage,
      :salary, :siblings, :profession, :dream_for_future, :settled_in
    ]
  # add types for profession
  
  # has_many :recommendation, :dependent => destroy
  has_one :subscription
  has_many :hobby
  has_many :interested_in
  has_many :not_interested_in
  
  # scope :in_requests , {:joins => " INNER JOIN requests ON users.id=requests.to_id" , :conditions => [ "requests.status = 1"] }
  # scope :out_requests , {:joins => " INNER JOIN requests ON users.id=requests.from_id" , :conditions => [ "requests.status = 1"] }
  # scope :in_requests, lambda { |id| where('requests.to_id = ?', id) }

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end
  
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  # Generic method to deliver notifications for a pre-decided event
  # Delivers the following :-
  # => 1) Notification to the passed user object
  # => 2) mail to the passed user object
  # => 3) SMS alert to the passed user if it is allowed
  # Also if some special operation is to be carried out after sending notification,
  # the name of the method is picked up from the `operation` key and called with
  # the existing plus self parameter.
  # 
  # PS: Independent handling within these methods is expected.
  #
  # @param [Symbol] event
  #   Symbol for the event 
  def deliver_notifications(event, args = [])
    event = CONTACT_TEMPLATES[event]
    Notification.send_notification(event[:notif], args << self) if event[:notif]
    Notifier.deliver_mail(event[:mail], args << self) if event[:mail]
    SmsDelivery.send_sms(event[:sms], args << self) if event[:sms] and self.is_phone_notif_allowed?
    self.send(event[:operation].to_sym, args << self) if event[:operation]
  end
  
  # Checks if phone notification is allowed for the user
  # @return [TrueClass|FalseClass]
  def is_phone_notif_allowed?
    !self.phone.blank?
  end
  
  # Removes the request from the receiver's dashboard.
  # @param [Array] args
  #     An array of receiver id, then sender id for the request.
  #     The corresponding request is found and destroyed.
  #     On next view of the receiver's profile, this request will not be present
  #     Hence not shown to her/him. Silent assassination :-)
  def remove_request(*args)
    if args.length
      receiver_id = args.first.id
      sender_id = args.last.id
      Request.find_by_from_id_and_to_id(sender_id, receiver_id).destroy rescue nil
    end
  end
  
  ### PAID SECTION STARTS ###
  
  # Returns whether the user is paid or not
  # @return [TrueClass|FalseClass] 
  def is_paid?
    !self.subscription.blank?
  end
  
  # Returns whether subscription has expired or not
  # @return [TrueClass|FlaseClass]
  def is_still_paid?
    self.subscription.status == Subscription::ACTIVE
  end
  
  ### PAID SECTION ENDS ###
  
  ### LOCK SECTION STARTS ###
  
  # Returns whether the user is available or in a locked state
  # @return [TrueClass|FalseClass]
  def is_available?
    self.status == AVAILABLE
  end
  
  # Updates the number of active locks right now post he withdraws a lock
  def update_status_post_lock_withdraw
    self.num_active_locks -= 1
    self.num_active_locks = 0 if self.num_active_locks < 0
    self.save!
  end
  
  # Locks the two users and saves their states
  # @param [User] a
  #     First User to be locked
  # @param [User] b
  #     Second User to be locked
  def self.lock_users(a, b)
    a.status = LOCKED
    b.status = LOCKED
    a.locked_since = b.locked_since = Time.now.to_date
    a.locked_with = b
    b.locked_with = a
    
    a.save!
    b.save!
  end
  
  # I have notified that my lock was successful
  # Will save time and status to my profile
  # @return [TrueClass|FalseClass] denoting the success or failure of the operations    
  def request_mark_as_married
    begin
      self.status = MARK_MARRIED
      self.notifying_for_success_date = Time.now.to_date
      self.save!
    rescue
      return false
    end
    return true
  end
  
  # Sends notification for confirmation to the other person of my lock
  # when I notify that lock was successful
  def send_request_for_successful_lock
    notifying_user = User.find_by_id(self.locked_with) rescue nil
    notifying_user and self.deliver_notifications(:request_for_successful_lock, notifying_user)
  end
  
  # Class method to mark a couple as successfully married
  # Creates a new entry in couples table
  # @param [User] requesting_user
  # => The user who had requested to mark the success
  # @param [User] confirming_user
  # => The user who confirmed it
  # PS: This distinction is not required, but kept for future uses.
  # @return [TrueClass|FalseClass] denoting the success or failure of the operations  
  def self.mark_as_married(requesting_user, confirming_user)
    begin
      requesting_user.status = confirming_user.status = User::MARRIED
      requesting_user.marriage_informed_date = confirming_user.marriage_informed_date = Time.now.to_date
      requesting_user.save!
      confirming_user.save!
      couple = Couple.create({
        :one_id => confirming_user.id,
        :other_id => requesting_user.id,
        :deliberation_time => (Time.now.to_date - requesting_user.locked_since)
      })
      couple.save!
    rescue
      return false
    end
    return true
  end
  
  # I have notified that my lock is over
  # @return [TrueClass|FalseClass] denoting the success or failure of the operations  
  def request_mark_as_rejected
    begin
      self.status = MARK_REJECTED
      self.rejected_on = Time.now.to_date
      self.save!
    rescue
      return false
    end
    return true
  end
  
  # Sends request to user for confirming that reject actually happened
  def send_request_for_confirming_reject
    self.status = MARK_REJECTED
    self.save!
    
    reject_requesting_user = User.find_by_id(self.locked_with)
    self.deliver_notifications(:confirm_reject, [reject_requesting_user])
  end
    
  
  ### LOCK SECTION ENDS ###
  
  ### REQUEST SECTION STARTS ###
  
  # Determines if the user can send a request or not to any other user.
  # Checks are, he should be
  # => Not suspended
  # => Is paid
  # => Has an active subscription
  # => And is free, not in a locked state
  # @return [TrueClass|FalseClass]
  def can_send_request?
    !self.suspended? and self.is_paid? and self.is_still_paid? and self.is_available?
  end
  
  # Determines if the user subscription is still valid?
  # @return [TrueClass|FalseClass]
  def has_active_subscription?
    self.is_paid? and self.is_still_paid?
  end
  
  # Creates a new request object for a & b.
  # Also sends notification to b.
  # @param [User] b
  #     The receiver of the request 
  # @return [TrueClass|FalseClass] denoting if the request got created or not
  def create_new_request(b)
    begin
      req = Request.create
      req.from_id = self.id
      req.to_id = b.id
      req.asked_date = Time.now.to_date
      req.save!
    rescue
      return false
    end
    self.deliver_notification(:request_notification, [b])
    return true
  end
  
  # Marks the request between self and from_user as accepted
  # Puts self and from_user in locked state
  # Sends notification to sender of request
  # @param [User] from_user
  #     The user who had sent the request
  def accept_request_from(from_user)
    begin
      Request.set_as_accepted(self.id, from_user.id)
      lock = Lock.create({
        :one_id => self.id,
        :another_id => from_user.id,
        :creation_date => Time.now.to_date
      })
      lock.save!
    rescue
      return false
    end
    
    # this notification should contain link to see my personal info since I accepted his request.
    self.deliver_notifications(:request_accepted, [from_user])
    return true
  end
  
  # Marks the request between self and from_user as declined
  # Sends notification to sender of request
  # @param [User] from_user
  #     The user who had sent the request
  def decline_request_from(from_user)
    Request.set_as_declined(self.id, from_user.id)
    self.deliver_notifications(:request_declined, [from_user])
  end
  
  # Marks the request between self and from_user as withdrawn
  # Removes the notification from self to the recipient
  # @param [User] to_user
  #     The user to whom the request was sent
  def withdraw_request_to(to_user)
    Request.set_as_withdrawn(to_user.id, self.id)
    seld.deliver_notifications(:request_withdrawn, [from_user])
  end
  
  
  ### REQUEST SECTION ENDS ###

  ### AUTH SECTION STARTS ### 
  
  # Returns whether the user has verified his email
  # @return [TrueClass|FalseClass]
  def verified?
    self.verified == true
  end
  
  # Returns if user is marked for deletion or not.
  # @return [TrueClass|FalseClass] returns true if flag value relative to marked for deletion found for user , false otherwise.
  def marked_for_deletion?
    self.user_flag && self.user_flag.value == UserFlag::MARKED_FOR_DELETION
  end
  
  # Returns if user is suspended.
  # @return [TrueClass|FalseClass] returns true if flag value is suspended
  def suspended?
    self.user_flag && self.user_flag.value == UserFlag::SUSPENDED
  end
  
  # Returns whether the user is in a valid state to be logged in
  # @return [TrueClass|FalseClass]
  def is_active_user?
    self.verified? && !self.marked_for_deletion && !self.suspended?
  end
  
  ### AUTH SECTION ENDS ###
  
  # Removes the two users from search and recommendation results
  # @param [User] user
  # => The user to be removed
  def remove_from_searches(user)
  end
  
  def incoming_requests(fields="from_id")
    Request.find(:all ,
                  :conditions => ["status=0 AND to_id= (?) ",self.id],
                  :select => fields
                )
  end
  
  def outgoing_requests(fields="to_id")
    Request.find(:all ,
                  :conditions => ["status=0 AND from_id= (?) ",self.id],
                  :select => fields
                )
  end
  
  def viewer_pane_info(user_ids)
    user_ids.each do |id|
      
    end
  end
  
end


