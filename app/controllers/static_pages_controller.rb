class StaticPagesController < ApplicationController
  
  def home
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
    #render :layout => false
  end
  
  def copyright
    render :layout => false
  end
  
end
