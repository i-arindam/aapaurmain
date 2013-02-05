class ShortQuestionController < ApplicationController
  http_basic_authenticate_with :name => "creators", :password => "zenmakers", :only => :create_a_question
  
  def new_question
    @question = ShortQuestion.new
  end

  # Admin creates a question with answers.
  def create_a_question
    q = ShortQuestion.create({
      :text => params[:text],
      :belongs_to_topic => params[:topic],
      :by => params[:by] || "admin",
      :by_id => params[:by_id]
    })
    params[:answers].each do |ans|
      a = q.short_answers.create({
        :text => ans.text,
        :choice_num => ans.choice  
      })
    end
    $r.hset("question:#{q.id}:answers", :num_choices, params[:answers].length)
    # Not setting the value of the answers to 0, as any increment will take care of initializing those keys
  end

  # User answers a question with a choice. As json response,
  # current numbers for all choices are shown.
  def answer_a_question
    user = current_user
    render_401 and return unless user
    question = ShortQuestion.find_by_id(params[:id])
    render_404 and return unless question

    obj = {
      :qid => params[:id],
      :answer => params[:choice]
    }
    
    answers = {}
    $r.multi do
      $r.lpush("user:#{user.id}:questions", obj)
      $r.hincrby("question:#{question.id}:answers", "choice#{params[:choice]}", 1)
      choices = $r.hget("question:#{question.id}:answers", :num_choices)
      for i in 1..choices
        answers[i] = $r.hget("question:#{question.id}:answers", "choice#{i}")
      end
    end
    render :json => {
      :success => true,
      :answers => answers
    }
  end

  # AJAX endpoint.
  # Get n answers for a user. Handles offset and limit.
  # Returns the answers in json form.
  def get_answers_for
    user = current_user
    render_401 and return unless user
    prospect = User.find_by_id(params[:for_user_id])
    render_404 and return unless prospect

    answers = ShortQuestion.get_top_n_answers_for(prospect.id, params[:num], params[:start])
    render :json => {
      :success => true,
      :answers => answers
    }
  end

end
