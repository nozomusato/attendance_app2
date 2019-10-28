Rails.application.routes.draw do

  root 'static_pages#home'
  get  '/signup',   to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  # get '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info  勤怠Aでは使わない
  # patch 'update-basic-info',  to: 'users#update_basic_info'  勤怠Aでは使わない
  
  #勤怠編集画面
  get 'users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch 'users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  
  
  
  #残業申請
  post '/overwork_request/:id', to: 'users#overwork_request', as: :overwork_request
  patch '/users/:id/attendances/:attendance_id/update_overwork_request',  to: 'attendances#update_overwork_request', as: :update_overwork_request
  
  #残業申請受け取り、承認
  post '/overwork_permit', to: 'users#overwork_permit', as: :overwork_permit_modal
  patch '/users/attendances/overwork_permit', to: 'attendances#overwork_permit', as: :overwork_permit
  
  #１ヶ月分の勤怠申請、承認
  post '/month_request', to: 'users#month_request', as: :month_request_modal
  patch '/users/attendances/month_request', to: 'attendances#month_request', as: :month_request
  
   #勤怠変更申請、承認
  post '/edit_request', to: 'users#edit_request', as: :edit_request_modal
  patch '/users/attendances/edit_request', to: 'attendances#edit_request', as: :edit_request
  
  
  
  #出勤中社員
  get 'working_now',  to: 'users#working_now'
  
  resources :users do
    collection { post :import }
  resources :attendances, only: :create
  end
  
  resources :basepoints do
    member do
      get 'edit_base'
      patch 'update_base'
    end
  end
  
  
  
end