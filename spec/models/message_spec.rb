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

require 'spec_helper'

describe Message do
  pending "add some examples to (or delete) #{__FILE__}"
end
