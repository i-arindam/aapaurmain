# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  from_id       :integer          not null
#  to_id         :integer          not null
#  ask_time      :datetime
#  text          :string(255)
#  response_time :datetime
#  response_type :integer
#  response_text :string(255)
#  flagged       :boolean
#  flagged_time  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Question < ActiveRecord::Base
  # attr_accessible :title, :body
end
