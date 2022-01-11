Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  root 'home#index'

  post '/sign_up', to: 'users#sign_up'
  post '/sign_in', to: 'users#sign_in'

  get '/me', to: 'users#show'
  put '/me', to: 'users#update'
  put '/update_contacts', to: 'users#update' # synonym for PUT /me for swagger doc generation
  delete '/me', to: 'users#destroy'

  resources :friendships
end
