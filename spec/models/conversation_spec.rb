# == Schema Information
#
# Table name: conversations
#
#  id           :integer          not null, primary key
#  from_user_id :integer          not null
#  to_user_id   :integer          not null
#  snippet      :string(100)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Conversation do
  pending "add some examples to (or delete) #{__FILE__}"
end
