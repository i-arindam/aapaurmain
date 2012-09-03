class SearchController < ApplicationController
  
  def base_url
    url = $search_conf[Rails.env]['host']
    url += ":#{$search_conf[Rails.env]['port']}" unless $search_conf[Rails.env]['port'].nil?
    url += "/solr/"
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
  
  def keyword_search
    @show_nothing = true if params[:q].blank?
    return if @show_nothing
    
    qf, q = form_keyword_search_query(params[:q])
    solr = RSolr.connect :url => base_url
    
    @response = solr.get 'select', :params => { 
      :q => q,
      :qf => qf,
      :wt => :ruby,
      :start => 0,
      :rows => 100,
      :defType => $search_conf['keyword_search']['defType'],
      :fl => $search_conf['keyword_search']['fl'].join(",")
    }
    
    user_ids = []
    @response["response"]["docs"].each { |d| user_ids.push(d["id"].to_i) }

    @users = User.find_all_by_id(user_ids)
  end
  
end
