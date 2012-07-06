class SessionsController < ApplicationController
  
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password]) 
      if user.is_active_user?
        session[:user_id] = user.id
        # @todo replace root_url with user dashboard
        redirect_to root_url, :notice => "Log in successful!"
      else
        redirect_to root_url, :alert => "You are not authorized to sign in!"
      end
    else
      flash[:alert] = "Invalid email or password"
      render "new" # This will be sign in page 
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end