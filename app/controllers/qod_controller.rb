class QodController < ApplicationController

  def current
    QotdQuestion.last.id
  end

  def show
    question = QotdQuestion.find_by_id params[:id]
    render :json => { :success => false, :payload => "Incorrect question probed" } and return unless question

    answers = question.latest_n_answers(params[:n] || 10)
    user_answers = []
    answers.each do |an|
      user_answers.push({
        :text => an.answer,
        :by => (u = User.find_by_id(an.answer_by) and u.name) || "Anon User",
        :by_id => an.answer_by,
        :when => an.updated_at.to_s
      })
    end

    to_render = {
      :success => true,
      :payload => {
        :question => {
          :text => question.question,
          :when => question.updated_at.to_s,
          :by => question.question_by_name,
          :is_admin => question.admin_generated,
          :likes => (question.likes > 10 ? question.likes : 0),
          :dislikes => (question.dislikes < 3 ? question.dislikes : 0)
        },
        :answers => {
          :size => answers.size,
          :user_answers => user_answers
        }
      }
    }

    render :json => to_render.to_json
  end

  def create_answer
    question = QotdQuestion.find_by_id(params[:id])
    render :json => {
      :success => false,
      :payload => "Sorry thats not the Question Of the Day"
    } and return unless question and question == QotdQuestion.last
    
    new_answer = question.qotd_answers.create( :answer => params[:text], :answer_by => params[:creator_id] )

    render :json => {
      :success => false,
      :payload => "That answer could not be created due to an error. Please try again?"
    } and return unless new_answer

    render :json => {
      :success => true,
      :payload => {
        :answer => {
          :text => new_answer.answer,
          :by => (u = User.find_by_id(new_answer.answer_by) and u.name) || "Anon User",
          :by_id => new_answer.answer_by,
          :when => new_answer.updated_at.to_s
        }
      }
    }
  end

end
