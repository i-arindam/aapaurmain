class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  def render_404
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end
  
  def verify_dob(hash)
    return true
  end
  
  def get_date(hash)
    return Time.now.to_date
  end
  
  def verify_age(dob, sex)
    return true
  end
  

  def current_user
    User.find_by_auth_token!(cookies[:auth_token]) if !cookies[:auth_token].blank?
  end
  helper_method  :current_user
  
end
