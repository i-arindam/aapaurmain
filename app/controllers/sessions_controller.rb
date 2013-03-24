class SessionsController < ApplicationController
  
  def new
  end
  
  def create

    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password]) 
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      route_to = (user.sex ? "/dashboard" : "/users/#{user.id}/create_profile")
      redirect_to route_to
    else
      redirect_to root_url, :alert => "Invalid email or password"
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url
  end
end
