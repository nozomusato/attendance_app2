Rails.application.routes.draw do

  root 'static_pages#home'
  get  '/signup',   to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info
  patch 'update-basic-info',  to: 'users#update_basic_info'
  get 'users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch 'users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  get 'working_now',  to: 'users#working_now'
  
  resources :users do
    collection { post :import }
  resources :attendances, only: :create
     member do
       get 'request_overtime'
       get 'receive_overtime'
       get 'edit_attendance'
       get 'month_approval'
     end
  end
  
  resources :basepoints do
    member do
      get 'edit_base'
      patch 'update_base'
    end
  end
  
  
end