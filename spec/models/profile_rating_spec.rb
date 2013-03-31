# == Schema Information
#
# Table name: profile_ratings
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  rated_user_id :integer          not null
#  score         :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe ProfileRating do
  pending "add some examples to (or delete) #{__FILE__}"
end
