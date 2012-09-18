class Message < ActiveRecord::Base
  attr_accessible :to, :from, :text
  belongs_to :conversation, :touch => true
end
