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
    Time.now.year - 75
  end
  
  # Returns the end year from the current time
  # 90 years is the set limit.
  # Used to show the maximum year one can show as DOB.
  # @todo: Move limit to globals.yml
  def end_year
    Time.now.year 
  end
  
  def join_as_string(user_field_array, field_name)
    field_values = []
    if user_field_array
      user_field_array.each do |value|
        field_values << value["#{field_name}"]
      end
      field_values.join(',')
    end
  end
  
  
  def profession_list
    list = $user_prefs['professions']
  end
  
  def relocate_list
    list = $user_prefs['relocate']
  end
  
  def spouse_pref_list
    list = $user_prefs['spouse_pref']
  end
  
  def virginity_opinion_list
    list = $user_prefs['virginity_opinion']
  end
  
  def further_education_list
    list = $user_prefs['further_education']
  end
  
  def family_preference_list
    list = $user_prefs['family_preference']
  end

  def sex_list
    list = $user_prefs['sex']
  end

  def sexual_pref_list
    list = $user_prefs['sexual_pref']
  end

  def salary_list
    list = $user_prefs['salary']
  end
  
  def show_login?
    (params[:controller] == "static_pages" and params[:action] == "home" and !current_user) or (params[:controller] == "users" and params[:action] == "signup") or !current_user
  end
  
  def show_search?
    !show_login?
  end

  def show_tip
    list = $user_tips['locked_tips']
    r= Random.rand(5)
    list[r]
  end

end
