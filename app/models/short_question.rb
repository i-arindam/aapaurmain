class ShortQuestion < ActiveRecord::Base
  has_many :short_answers

  def self.get_latest_n_answers_for(user_id, n = 2, start = 0)
    answers = []
    questions_answered = $r.lrange("user:#{user_id}:questions", start, n)
    questions_answered.each do |an_answer|
      an_answer = JSON.parse(an_answer)
      q = ShortQuestion.find_by_id(an_answer['qid'])
      a = ShortAnswer.find_by_short_question_id_and_choice_num(q.id, an_answer['answer'].to_i)
      answers.push({
        :q => q.text,
        :a => a.text
      })
    end
    answers
  end

  def self.get_latest_question_for(user_id)
    
  end
end
