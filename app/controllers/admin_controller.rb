class AdminController < ApplicationController
	http_basic_authenticate_with :name => "aapaurmain", :password => "mainauraap"

	def approve_request
		@user = User.find_by_id(params[:id])
		if @user.blank?
			render 404
		end
		@user.signup_status = User.APPROVED
	end

	def reject_request
		@user = User.find_by_id(params[:id])
		if @user.blank?
			render 404
		end

		@user.signup_status = User.REJECTED
	end

end
