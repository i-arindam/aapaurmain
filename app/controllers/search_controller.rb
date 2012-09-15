class SearchController < ApplicationController
  
  def base_url
    return @base_url if @base_url
    url = $search_conf[Rails.env]['host']
    url += ":#{$search_conf[Rails.env]['port']}" unless $search_conf[Rails.env]['port'].nil?
    url += "/solr/"
    @base_url = url
  end
  
  def basic_params
    base_params = $search_conf['basic_params']

    params = []
    base_params.each do |k, v|
      params.push("#{k}=#{v}") unless @override_params.include?(k)
    end
    params.join("&")
  end
  
  def form_keyword_search_query(query_string)
    fields = $search_conf['keyword_search']['fields']
    fields = fields.join(" ")
    
    query_string = "#{query_string}*"
    return fields, query_string
  end
  
  def form_advanced_search_query(form_hash)
    conf = $search_conf['advanced_search']
    fields = conf['fields']
    query_components = []
    
    fields.each do |f|
      value = form_hash["pref_#{f}"]
      query_components.push( "u_#{f}:#{value}" ) unless value.blank?
    end
    
    return query_components.join(" OR ")
  end
  
  def keyword_search
    @show_nothing = true if params[:q].blank?
    return if @show_nothing
    @current_user = current_user
    
    qf, q = form_keyword_search_query(params[:q])
    solr = RSolr.connect :url => base_url
    conf = $search_conf['keyword_search']
    
    @response = solr.get 'select', :params => { 
      :q => q,
      :qf => qf,
      :wt => :ruby,
      :start => 0,
      :rows => conf['rows'],
      :defType => conf['defType'],
      :fl => conf['fl'].join(",")
    }
    
    user_ids = []
    @response["response"]["docs"].each { |d| user_ids.push(d["id"].to_i) }

    @users = User.find_all_by_id(user_ids)
    render :search_results
  end
  
  def advanced_search
    @current_user = current_user
    
    q = form_advanced_search_query(params[:search])
    solr = RSolr.connect :url => base_url
    conf = $search_conf['advanced_search']
    
    @response = solr.get 'select', :params => {
      :q => q,
      :wt => :ruby,
      :start => 0,
      :rows => conf['rows'],
      :defType => conf['defType'],
      :fl => conf['fl'].join(",")
    }
    
    user_ids = []
    @response["response"]["docs"].each { |d| user_ids.push(d["id"].to_i) }
    
    @users = User.find_all_by_id(user_ids)
    render :search_results
  end
  
end
