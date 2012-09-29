class StaticPagesController < ApplicationController
  
  def home
  end
  
  def help
  end
  
  def about
  end
  
  def contact
  end
  
  def how_it_works
    render :layout => false
  end
  
  def faq
    render "faq", :layout => false
  end
  
end
