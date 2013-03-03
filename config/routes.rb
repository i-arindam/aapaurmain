Aapaurmain::Application.routes.draw do
  get "log_out" => "sessions#destroy", :as => "logout"
  get "log_in" => "sessions#new", :as => "login"
  get "sign_up" => "users#new", :as => "signup"

  # static pages
  root to: 'static_pages#home'
  match '/tnc',    to: 'static_pages#tnc'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/faq', to: 'static_pages#faq'
  match '/howitworks', to: 'static_pages#how_it_works'
  match '/pricing', to: 'payment#pricing'
  match '/privacy', to: 'static_pages#privacy'
  
  get 'users/:id/more_info' => 'users#more_info'

  resources :users
  resources :sessions
  resources :password_resets

  post 'users/signup' => 'users#signup'
  match '/signup/confirmation' => 'users#confirm_signup'
  match '/users/:id/create_profile' => 'users#create_profile'  
  
  # Request actions
  post 'users/:id/upload_photo' => 'users#upload_photo'
  post 'users/:id/delete_photo' => 'users#delete_photo'
  post 'users/:id/show_viewers' => 'users#show_viewers'
  
  
  # Post lock actions
  post 'users/withdraw_lock' => 'users#withdraw_lock'
  post 'users/:id/locks/:lock_id/withdraw' => 'users#withdraw_lock'
  post 'users/:id/locks/:lock_id/finalize' => 'users#finalize_lock'
  post 'users/:id/lock/request_confirm' => 'users#request_confirm_locked'
  post 'users/:id/lock/confirm_success' => 'users#confirm_success'
  

  # Search actions
  get 'search/keyword_search' => 'search#keyword_search'
  post '/search/advanced_search' => 'search#advanced_search'
  
  #Chat actions
  resources :chat
  match '/pusher/auth' => 'chat#auth'
  
  # Conversations and messages
  get 'conversations' => 'conversation#conversations'
  get 'conversations/new' => 'conversation#create'
  get 'conversations/:id' => 'conversation#show'
  post 'conversations/:id/new_message' => 'conversation#new_message'

  # Admin actions
  match 'admin/:action' => 'admin'

  # Qod actions
  get '/qod/:id' => 'qod#show'
  post '/qod/:id/answers/new' => 'qod#create_answer'

  # User Activity section
  post 'story/:story_id/do' => 'story#like_dislike_or_comment'
  post 'story/:story_id/comment/:number/do' => 'story#like_dislike_a_comment'
  post 'story/create' => 'story#create_new_story'
  match 'story/:id' => 'story#show'

  get 'story/:story_id/get' => 'story#get_persons_on_story_actions'

  get 'story/:story_id/get/comment/:number/:action' => 'story#get_comment_faces'
  
  match 'panel/:name' => 'panel#show'
  get 'panel/:name/get/more/:start/:num' => 'panel#show_more_stories'

  # New routes
  match 'home' => 'users#home'
  get '/edit_profile' => 'users#edit_profile'
  post '/update' => 'users#update'

  # Left panel links
  match '/dashboard' => 'users#my_dashboard'

  match '/my/panels' => 'users#my_panels'
  match '/my/requests/:direction' => 'users#show_requests'
  match '/people/i/like' => 'users#people_i_follow'
  match '/people/like/me' => 'users#people_follow_me'
  match '/my/top/stories' => 'users#my_top_stories'

  # Panels pages
  match '/panels/:name' => 'panel#show'
  # Per user links
  post '/request/:user_id/send' => 'users#create_request'
  post '/request/:id/cancel' => 'users#withdraw_request'
  post '/request/:id/accept' => 'users#accept_request'
  post '/request/:id/decline' => 'users#decline_request'

  post '/follow/user/:id/:type' => 'users#follow_user', :defaults => { :type => 0 }
  post '/unfollow/user/:id' => 'users#unfollow_user'
  post '/rate/profile/:id/:star' => 'users#rate_profile', :defaults => { :star => 1 }
  match '/persona/:id' => 'users#show'

  # Ajax links. These come from list pages and/or full profile page
  get '/panels/all/:id/:for_user_id' => 'users#get_all_panels_info'
  get '/stories/top/:for_user_id' => 'users#get_top_stories'
  get '/stories/all/:for_user_id' => 'users#get_all_stories'
  get '/stories/more/:for_user_id/:start' => 'users#get_more_stories', :defaults => {:start => 10}

  # Questions actions
  match '/question/create' => 'short_question#new_question'
  post '/question/save' => 'short_question#create_a_question'
  post '/question/:id/answer/:choice' => 'short_question#answer_a_question'
  get '/questions/latest/:for_user_id/:num' => 'short_question#get_answers_for', :defaults => { :num => 2 }
  get '/questions/more/:for_user_id/:start/:num' => 'short_question#get_answers_for', :defaults => { :start => 3, :num => 5 }

  # Ajax endpoints for dom content
  get '/get/dom/all' => 'users#get_all_dom_partials'
end
