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

class ProfileRating < ActiveRecord::Base
  attr_accessible :rated_user_id, :score
  belongs_to :user
end
