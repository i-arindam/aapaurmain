# class AccountController < ApplicationController
#   To be merged in SessionController 
#   
#   
#   def signup
#     #Check if email id is already registered
#     # if name is already taken -> should be ajax check also
#     # if user already exists then take him to his profile
#     render :text => "Name is already taken" and return unless username_available(params[:name]) 
#     render :text => "E-mail is already registered" and return unless email_available(params[:email])
#     
#     #set response header
#     
#     #create user ,set session and send confirmation email   
#     @user = User.create(params[:user])
#     session[:user] = @user
#     @confirm_id=Notifier.confirm_id(@user)
#     
#      # Deliver notification for new signups
#     # Notifier.deliver_signup_notification(@user, @confirm_id, params[:download_id])
#     
#   end
#   
#   def confirm_user
#     
#   end
#   
#   
#   # Checks for following
#   # user is not suspended
#   # user is not marked for deletion
#   # user has confirmed his email 
#   def login
#     user=User.find_by_email(params[:email])
#     render :text => "Invalid login details.Please try again" and return if user.nil?
#      if user.suspended?
#         message = "Login unsuccessful. Your account has been suspended as it was found to be in violation of T & C "
#         render :json => { :success => false, :message => message }.to_json and return if request.xhr?
#         flash[:notice]  = message        
#         # @login = params[:user_login]
#       elsif user.marked_for_deletion?
#         message = "The account does not exist."
#         render :json => { :success => false, :message => message }.to_json and return if request.xhr?
#         flash[:notice]  = message   
#       # If the user is found but is not yet verified
#       elsif !user.verified?
#         message = "Login unsuccessful. Your email has not been verified, please login with your username instead."
#         render :json => { :success => false, :message => message }.to_json and return if request.xhr?
#         flash[:notice]  = message
#       # If user could be authenticated  
#       elsif user.is_valid_password?(params[:password])
#         
#       else
#       end
#   end
#   
# end