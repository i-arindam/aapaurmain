class AdminController < ApplicationController
	http_basic_authenticate_with :name => "aapaurmain", :password => "mainauraap"

	def approve_request
		@user = User.find_by_id(params[:id])
		if @user.blank?
			render 404
		end

		@user.approve_profile_update
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
		@new_profile = user.profile_updates.find(:first, :conditions => ['status=?',0]) unless user.profile_updates.blank?
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
