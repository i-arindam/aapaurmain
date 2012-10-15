class Conversation < ActiveRecord::Base
  attr_accessible :from_user_id, :to_user_id
  has_many :messages, :dependent => :destroy
  validates :from_user_id, :presence => true, :length => { :in => 1..11 }, :numericality => true
  validates :to_user_id, :presence => true, :length => { :in => 1..11 }, :numericality => true
  
  def set_snippet(snippet_from_message)
    self.snippet = snippet_from_message
  end # End set_snippet
  
end # End Conversation

