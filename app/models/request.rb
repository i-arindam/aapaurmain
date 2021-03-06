# == Schema Information
#
# Table name: requests
#
#  id            :integer          not null, primary key
#  from_id       :integer          not null
#  to_id         :integer          not null
#  status        :integer          default(0)
#  approved_date :datetime
#  rejected_date :datetime
#  asked_date    :datetime
#  withdraw_date :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

##############################################################################
# @attr [Fixnum(11)] id             
# @attr [Fixnum(11)] from_id        
# @attr [Fixnum(11)] to_id          
# @attr [Fixnum(4)] status         
# @attr [Date] approved_date  
# @attr [Date] rejected_date  
# @attr [Date] asked_date     
# @attr [Date] withdraw_date  
# @attr [Time] created_at     
# @attr [Time] updated_at     
##############################################################################
class Request < ActiveRecord::Base
  
  # Enumeration for status
  ASKED = 0
  ACCEPTED = 1
  DECLINED = 2
  WITHDRAWN = 3
  
  # Finds the relevant request object and sets status to accepted
  # @param [Fixnum] to_id
  #     The id of the user to which the request was sent, and who approved it
  # @param [Fixnum] from_id
  #     The id of the user who sent the request.
  def self.set_as_accepted(to_id, from_id)
    req = Request.find_by_from_id_and_to_id(from_id, to_id) rescue nil
    if req
      req.status = ACCEPTED
      req.approved_date = Time.now.to_date
      req.save!
      return true
    end
    return false
  end
  
  # Finds the relevant request object and sets status to declined
  # @param [Fixnum] to_id
  #     The id of the user to which the request was sent, and who declined it
  # @param [Fixnum] from_id
  #     The id of the user who sent the request.
  def self.set_as_declined(to_id, from_id)
    req = Request.find_by_from_id_and_to_id(from_id, to_id) rescue nil
    if req
      req.status = DECLINED
      req.rejected_date = Time.now.to_date
      req.save!
    end
  end
  
  

   # Finds the relevant request object and sets status to ASKED
  # @param [Fixnum] to_id
  #     The id of the user to which the request was sent
  # @param [Fixnum] from_id
  #     The id of the user who sent the request, and who withdrew it
  def self.set_as_asked(to_id, from_id)
    req = Request.find_by_from_id_and_to_id(from_id, to_id) rescue nil
    if req
      req.status = ASKED
      req.withdraw_date = Time.now.to_date
      req.save!
    end
  end
  
  def self.requests_sent_to_me(my_id)
    reqs = Request.find_all_by_to_id(my_id) rescue nil
    reqs.delete_if { |r| [WITHDRAWN, DECLINED].include?(r.status) }
    reqs
  end

  def self.requests_sent_by_me(my_id)
    reqs = Request.find_all_by_from_id(my_id) rescue nil
    reqs.delete_if { |r| [WITHDRAWN, DECLINED].include?(r.status) }
    reqs
  end

  def sent?
    self.status == ASKED
  end

  def accepted?
    self.status == ACCEPTED
  end

  def declined?
    self.status == DECLINED
  end

  def withdrawn?
    self.status == WITHDRAWN
  end

  def get_for_display(direction)
    values = {}
    if direction == 'in'
      get_display_for_incoming_requests(values)
    else
      get_display_for_outgoing_requests(values)
    end
    values
  end

  def get_display_for_incoming_requests(values)
    if self.sent?
      values['text'] = 'Accept'
      values['href'] = "#request_accept"
      values['special'] = "/request/#{self.id}/accept"
    elsif self.declined?
      values['text'] = 'Request once declined'
      values['href'] = '#request_declined'
      values['special'] = 'blank'
    elsif self.accepted? # These 2 are in lock state
      values['text'] = 'Break Lock'
      values['href'] = '#request_break'
      values['special'] = "/request/#{self.id}/break"
    end
  end

  def get_display_for_outgoing_requests(values)
    if self.sent?
      values['text'] = 'Withdraw'
      values['href'] = "#request_withdraw"
      values['special'] = "/request/#{self.id}/cancel"
    elsif self.withdrawn?
      values['text'] = 'Request once sent'
      values['href'] = '#request_sent'
      values['special'] = 'blank'
    elsif self.accepted? # These 2 are in lock state
      values['text'] = 'Break Lock'
      values['href'] = '#request_break'
      values['special'] = "/request/#{self.id}/break"
    end
  end

  def self.get_request_values(current, other)
    values = {}
    req = Request.find_by_from_id_and_to_id(current, other)

    if req # Current user has a sent request to the other user
      req.get_display_for_outgoing_requests(values)
    elsif req = Request.find_by_from_id_and_to_id(other, current) # Current user has a request from other user
      req.get_display_for_incoming_requests(values)
    else # No request b/w these 2 ever existed
      values['text'] = 'Send Request'
      values['special'] = "/request/#{other}/send"
      values['href'] = '#request_send'
    end
    values
  end

end
