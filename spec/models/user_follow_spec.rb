# == Schema Information
#
# Table name: user_follows
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  following_user_id :integer          not null
#  follow_type       :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe Following do
  pending "add some examples to (or delete) #{__FILE__}"
end
