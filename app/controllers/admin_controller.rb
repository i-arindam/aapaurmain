class AdminController < ApplicationController
	http_basic_authenticate_with :name => "aapaurmain", :password => "mainauraap"

	def approve_request
		@user = User.find_by_id(params[:id])
		render_404 and return if @user.blank?
		@user.signup_status = User.APPROVED
	end

	def reject_request
		@user = User.find_by_id(params[:id])
		if @user.blank?
			render 404
		end

		@user.signup_status = User.REJECTED
	end


	def show_profile_udpates
		return if params[:email].blank?
		@user = User.find_by_email params[:email]
		flash[:error] = "User not found." and return if @user.blank?
		get_latest_profile_update(@user)
	end

	def get_latest_profile_update(user)
		profile_update = user.profile_updates.find(:first, :conditions => ['status=?',0])
		@new_profile = JSON.parse profile_update.profile
	end

	def approve_profile_update
		@user = User.find params[:id]
		result = @user.approve_profile_update

		if result
			flash[:success] = "Profile update approved and profile udpated"
		else
			flash[:error] = "some error in updating profile"
		end
		render 'admin/show_profile_udpates'
	end

	def index
	end


end
