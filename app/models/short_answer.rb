class ShortAnswer < ActiveRecord::Base
  attr_accessible :text, :choice_num
  belongs_to :short_question
end
