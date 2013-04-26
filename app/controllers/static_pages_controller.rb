class StaticPagesController < ApplicationController
  
  def home
    redirect_to '/dashboard' and return if current_user
  end
  
  def tnc
  end
  
  def about
  end
  
  def contact
  end
  
  def how_it_works
    render :layout => false
  end
  
  def faq
  end
  
  def privacy
    
  end
  
end
