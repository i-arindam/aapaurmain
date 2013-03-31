# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  conversation_id :integer          not null
#  text            :string(3000)     not null
#  from            :integer          not null
#  to              :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Message < ActiveRecord::Base
  attr_accessible :to, :from, :text
  belongs_to :conversation, :touch => true
end
