class StaticPagesController < ApplicationController
  
  def home
    redirect_to '/dashboard' and return if current_user
  end
  
  def tnc
  end
  
  def about
    render_404 and return
  end
  
  def contact
  end
  
  def how_it_works
    render :layout => false
  end
  
  def faq
    render_404 and return
  end
  
  def privacy
    
  end
  
end
