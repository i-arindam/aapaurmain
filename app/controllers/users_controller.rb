class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      # @todo replace root_url with create profile url
      redirect_to root_url, :notice => "Sign up successful!"
    else
      # @todo Figure out what to do here if signup fails
      render "new"
    end
  end
end