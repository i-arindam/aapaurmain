# == Schema Information
#
# Table name: qotd_questions
#
#  id               :integer          not null, primary key
#  admin_generated  :boolean          default(TRUE)
#  question         :string(600)      not null
#  likes            :integer          default(0)
#  dislikes         :integer          default(0)
#  question_by_name :string(50)       default("admin")
#  question_by      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe QotdQuestion do
  pending "add some examples to (or delete) #{__FILE__}"
end
