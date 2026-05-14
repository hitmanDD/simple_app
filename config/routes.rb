Rails.application.routes.draw do
  # Страницы сброса паролей
  get 'password_resets/new'
  get 'password_resets/edit'
  
  # Главная страница приложения
  root "static_pages#home"
  
  # Статические страницы
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

    # Стенá профиля: вложенные маршруты для комментариев.
    # Создает пути вида:
    # POST   /users/:user_id/comments    => Добавить запись на стену
    # DELETE /users/:user_id/comments/:id => Удалить запись со стены
    resources :comments, only: [:create, :destroy]
  end

  # Маршруты для создания и удаления связей (подписки/отписки)
  # Используем только :create и :destroy
  resources :relationships,       only: [:create, :destroy]

  # Маршруты для заметок (наша кастомная фича)
  # Разрешаем создание и удаление заметок
  resources :notes,               only: [:create, :destroy]
  
  # Маршруты для активации аккаунта
  resources :account_activations, only: [:edit]
  
  # Маршруты для сброса пароля
  resources :password_resets,     only: [:new, :create, :edit, :update]
  
  # Маршруты для микросообщений (постов)
  resources :microposts,          only: [:create, :destroy]
end