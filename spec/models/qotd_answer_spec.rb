# == Schema Information
#
# Table name: qotd_answers
#
#  id          :integer          not null, primary key
#  question_id :integer          not null
#  answer      :string(160)      not null
#  answer_by   :integer          not null
#  likes       :integer          default(0)
#  dislikes    :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe QotdAnswer do
  pending "add some examples to (or delete) #{__FILE__}"
end
