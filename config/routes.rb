Aapaurmain::Application.routes.draw do
  get "password_resets/new"
  get "log_out" => "sessions#destroy", :as => "logout"
  get "log_in" => "sessions#new", :as => "login"
  get "sign_up" => "users#new", :as => "signup"

  root to: 'static_pages#home'

  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  
  match 'users/showme' => 'users#showme'
  get 'users/:id/more_info' => 'users#more_info'
  
  resources :users do
    resources :subscription
  end
  resources :sessions

  post 'users/signup' => 'users#signup'
  match '/users/:id/create_profile' => 'users#create_profile'
  match 'users/:id/update' => 'users#update'
  
  
  # Request actions
  post 'users/create_request' => 'users#create_request'
  post 'users/withdraw_request' => 'users#withdraw_request'
  post 'users/accept_request' => 'users#accept_request'
  post 'users/decline_request' => 'users#decline_request'
  
  
  # Post lock actions
  post 'users/withdraw_lock' => 'users#withdraw_lock'
  post 'users/:id/locks/:lock_id/withdraw' => 'users#withdraw_lock'
  post 'users/:id/locks/:lock_id/finalize' => 'users#finalize_lock'
  post 'users/:id/lock/request_confirm' => 'users#request_confirm_locked'
  post 'users/:id/lock/confirm_success' => 'users#confirm_success'
  post 'users/:id/lock/request_reject' => 'users#request_reject_locked'
  

  # Search actions
  get 'search/keyword_search' => 'search#keyword_search'
  post 'search/advanced_search' => 'search#advanced_search'
  
  #Chat actions
  resources :chat
  match '/pusher/auth' => 'chat#auth'
  
  # Conversations and messages
  get 'conversations' => 'conversation#conversations'
  get 'conversations/:id' => 'conversation#show'
  post 'conversations/:id/new_message' => 'conversation#new_message'
end
