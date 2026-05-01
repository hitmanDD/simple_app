Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  root "static_pages#home"
  
  get "/help",    to: "static_pages#help"
  get "/about",   to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get '/signup',  to: 'users#new'
  
  # Маршруты для сессий (вход/выход)
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  # Расширенные маршруты для пользователей (Глава 14)
  resources :users do
    # member добавляет маршруты к конкретному пользователю (через его id)
    member do
      get :following # страница тех, на кого подписан юзер (/users/1/following)
      get :followers # страница тех, кто подписан на юзера (/users/1/followers)
    end
  end

  # Маршруты для создания и удаления связей (подписки/отписки)
  # Используем только :create и :destroy
  resources :relationships,       only: [:create, :destroy]

  resources :notes,               only: [:create, :destroy]
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]

end