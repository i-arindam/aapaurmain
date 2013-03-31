# == Schema Information
#
# Table name: short_questions
#
#  id               :integer          not null, primary key
#  text             :string(1000)     not null
#  by_id            :integer
#  by               :string(255)      default("admin"), not null
#  belongs_to_topic :string(50)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe ShortQuestion do
  pending "add some examples to (or delete) #{__FILE__}"
end
