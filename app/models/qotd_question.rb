class QotdQuestion < ActiveRecord::Base
  # attr_accessible :title, :body

  has_many :qotd_answers, :dependent => :destroy, :foreign_key => :question_id

  def latest_n_answers(n = 10)
    self.qotd_answers.order("updated_at DESC").limit(n)
  end

end
