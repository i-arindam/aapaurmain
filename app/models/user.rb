#################################################################################
# This class represents users. 
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
  
  # Enumeration for family preference
  FAMPREF_NUCLEAR = 0
  FAMPREF_JOINT = 1
  FAMPREF_EXTENDED = 2
  
  # Enumeration for spouse preference
  SPOPREF_WORKING = 0
  SPOPREF_HOMEMAKER = 1
  
  # Enumeration for sexual preference
  SEXPREF_STRAIGHT = 0
  SEXPREF_HOMO = 1
  SEXPREF_BI = 2
  
  # Enumeration for sex
  MALE = 0
  FEMALE = 1
  
  # Enumeration for availability `status`
  AVAILABLE = 0
  LOCKED = 1
  
  # Enumeration for contacting templates
  CONTACT_TEMPLATES = {
    :confirm_locked_success => { :mail => 'confirm_locked_success', :sms => 'confirm_locked_success', :notif => 'confirm_locked_success' },
    :request_sent => { :mail => 'request_sent', :sms => 'request_sent', :notif => 'request_sent' },
    :request_accepted => { :mail => 'request_accepted', :sms => 'request_accepted', :notif => 'request_accepted' },
    :request_declined => { :mail => 'request_declined', :sms => 'request_declined', :notif => 'request_declined' },
    :request_withdrawn => { :operation => 'remove_request' }
  }
  # add types for profession
  
  has_many :recommendation, :dependent => destroy
  has_one :subscription
  

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
  
  ### LOCK SECTION ENDS ###
  
  ### REQUEST SECTION STARTS ###
  
  # Creates a new request object for a & b.
  # Also sends notification to b.
  # @param [User] b
  #     The receiver of the request 
  def create_new_request(b)
    req = Request.create
    req.from_id = self.id
    req.to_id = b.id
    req.asked_date = Time.now.to_date
    req.save!
    
    self.deliver_notification(:request_notification, [b])
  end
  
  # Marks the request between self and from_user as accepted
  # Puts self and from_user in locked state
  # Sends notification to sender of request
  # @param [User] from_user
  #     The user who had sent the request
  def accept_request_from(from_user)
    Request.set_as_accepted(self.id, from_user.id)
    self.lock_users(self, from_user)
    
    # this notification should contain link to see my personal info since I accepted his request.
    self.deliver_notifications(:request_accepted, [from_user])
    remove_from_searches(self, from_user)
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

end
