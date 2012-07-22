module ApplicationHelper
  def full_title(page_title)
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
  # Returns the start year from the current time
  # 18 years is the set limit.
  # Used to show the minimum year one can show as DOB.
  # @todo: Move limit to globals.yml
  def start_year
    Time.now.year - 18
  end
  
  # Returns the end year from the current time
  # 90 years is the set limit.
  # Used to show the maximum year one can show as DOB.
  # @todo: Move limit to globals.yml
  def end_year
    Time.now.year - 90
  end
  
end
