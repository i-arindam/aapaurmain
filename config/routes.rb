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

  resources :users do
    resources :subscription
  end
  resources :sessions
  resources :password_resets

  post 'users/signup' => 'users#signup'
  match '/signup/confirmation' => 'users#confirm_signup'
  match '/users/:id/create_profile' => 'users#create_profile'  
  
  # Request actions
  post 'users/create_request' => 'users#create_request'
  post 'users/withdraw_request' => 'users#withdraw_request'
  post 'users/accept_request' => 'users#accept_request'
  post 'users/decline_request' => 'users#decline_request'
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
  post 'story/:story_id/action/:action' => 'story#like_dislike_or_comment'
  post 'story/:story_id/comment/:number/:action' => 'story#like_dislike_a_comment'
  post 'story/create' => 'story#create_new_story'
  get 'story/:story_id/get/:action' => 'story#get_interactions_on_story'
  get 'story/:story_id/get/more_comments' => 'story#get_more_comments'
  get 'story/:story_id/get/comment/:number/:action' => 'story#get_comment_faces'
  match 'panel/:name' => 'panel#show'
  get 'panel/:name/get/more/:start/:num' => 'panel#show_more_stories'

  # New routes
  match 'home' => 'users#home'
  get '/edit_profile' => 'users#edit_profile'
  post '/update' => 'users#update'

  # Left panel links
  match '/my/panels' => 'users#my_panels'
  match '/my/requests/:direction' => 'users#show_requests'
  match '/people/i/like' => 'users#people_i_follow'
  match '/people/like/me' => 'users#people_follow_me'
  match '/my/top/stories' => 'users#my_top_stories'

  # Per user links
  post '/request/:user/send' => 'users#create_request'
  post '/request/:user/cancel' => 'users#withdraw_request'
  post '/request/:user/accept' => 'users#accept_request'
  post '/request/:user/decline' => 'users#decline_request'

  post '/follow/user/:id/:type' => 'users#follow_user', :defaults => { :type => 0 }
  post '/unfollow/user/:id' => 'users#unfollow_user'
  post '/rate/profile/:id/:star' => 'users#rate_profile', :defaults => { :star => 1 }
  match '/persona/:id' => 'users#show'

  # Ajax links. These come from list pages and/or full profile page
  get '/panels/all/:id/:for_user_id' => 'users#get_all_panels_info'
  get '/questions/top/:for_user_id' => 'users#get_top_questions'
  get '/questions/all/:for_user_id' => 'users#get_all_questions'
  get '/stories/top/:for_user_id' => 'users#get_top_stories'
  get '/stories/all/:for_user_id' => 'users#get_all_stories'
end
