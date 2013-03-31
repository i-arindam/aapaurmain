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

class QotdQuestion < ActiveRecord::Base
  # attr_accessible :title, :body

  has_many :qotd_answers, :dependent => :destroy, :foreign_key => :question_id

  def latest_n_answers(n = 10, offset = 0)
    self.qotd_answers.order("updated_at DESC").limit(n).offset(offset)
  end

end
