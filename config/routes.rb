Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'

  root 'home#index'
  post '/sign-up', to: 'users#sign_up'
  post '/sign-in', to: 'users#sign_in'
end
