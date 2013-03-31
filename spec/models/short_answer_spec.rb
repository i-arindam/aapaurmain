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

require 'spec_helper'

describe ShortAnswer do
  pending "add some examples to (or delete) #{__FILE__}"
end
