class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
    def session_user
      @session_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
end
