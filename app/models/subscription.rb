##############################################################################
# @attr [int(11)] id                 
# @attr [date] start_date         
# @attr [date] end_date           
# @attr [tinyint(4)] subs_type          
# @attr [date] remind_date_start  
# @attr [int(11)] user_id            
# @attr [date] renew_date         
# @attr [tinyint(4)] renew_type         
# @attr [datetime] created_at         
# @attr [datetime] updated_at         
##############################################################################

class Subscription < ActiveRecord::Base
  belongs_to :user
  
  # Enumeration for subscription type
  MONTHS_3 = 1
  MONTHS_6 = 2
  MONTHS_12 = 4
  
  # Enumeration for subscription status
  ACTIVE = 0
  EXPIRED = 1
  
  # Enumeration for remind time
  REMIND_TIME = 7

  # Sets the status to expired.
  def expire_now
    self.status = EXPIRED
    self.save!
  end
  
  # Renews subscription with the specified type
  # Accordingly sets renew details, end date and remind date
  # @param [Integer] renew_type
  #     Enumerated value for renewal type
  def renew_now(renew_type)
    self.status = ACTIVE
    self.renew_type = self.subs_type = renew_type
    self.renew_date = Time.now.to_date
    self.end_date = self.renew_date + (90 * renew_type).days
    self.remind_date = self.end_date - REMIND_TIME.days
    self.save!
  end
  
end
