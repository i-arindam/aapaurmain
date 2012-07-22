Aapaurmain::Application.routes.draw do
  get "password_resets/new"
  get "log_out" => "sessions#destroy", :as => "logout"
  get "log_in" => "sessions#new", :as => "login"
  get "sign_up" => "users#new", :as => "signup"

  root to: 'static_pages#home'

  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'

  resources :users do
    resources :subscription
  end
  resources :sessions

  post 'users/signup' => 'users#signup'
  match '/users/:id/create_profile' => 'users#create_profile'
  match 'users/:id/update' => 'users#update'
  
  # Request actions
  post 'users/:from_id/request/:to_id' => 'users#create_request'
  post 'users/:to_id/request/:from_id/accept' => 'users#accept_request'
  post 'users/:to_id/request/:from_id/decline' => 'users#decline_request'
  
  # Post lock actions
  post 'users/:id/locks/:lock_id/withdraw' => 'users#withdraw_lozck'
  post 'users/:id/locks/:lock_id/finalize' => 'users#finalize_lock'
  post 'users/:id/lock/request_confirm' => 'users#request_confirm_locked'
  post 'users/:id/lock/confirm_success' => 'users#confirm_success'
  post 'users/:id/lock/request_reject' => 'users#request_reject_locked'
  
end
