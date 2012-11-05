class QotdAnswer < ActiveRecord::Base
  attr_accessible :answer, :answer_by
  belongs_to :qotd_question, :foreign_key => :question_id
end
