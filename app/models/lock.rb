#################################################################################

class Lock < ActiveRecord::Base
  
  # Enumeration for state of lock
  CREATED = 0
  WITHDRAWN = 1
  FINAL = 2
  FAILED = 3
  SUCCESS = 4
  
  def update_withdrawn
    self.status = WITHDRAWN
    self.save!
  end
  
  def is_active?
    self.status != WITHDRAWN or self.status != FAILED
  end
  
end
