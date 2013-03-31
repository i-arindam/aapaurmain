# == Schema Information
#
# Table name: short_answers
#
#  id                :integer          not null, primary key
#  short_question_id :integer
#  choice_num        :integer
#  text              :string(1000)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ShortAnswer < ActiveRecord::Base
  attr_accessible :text, :choice_num
  belongs_to :short_question
end
