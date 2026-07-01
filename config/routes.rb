Rails.application.routes.draw do
  # Главная страница приложения
  root "static_pages#home"

  # Страницы сброса паролей
  get 'password_resets/new'
  get 'password_resets/edit'
  
  # Статические страницы
  get "/help",    to: "static_pages#help"
  get "/about",   to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get '/signup',  to: 'users#new'
  
  # Маршруты для сессий (вход/выход)
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  # --- ИСПРАВЛЕНИЕ ЯДРА МАРШРУТОВ ПОЛЬЗОВАТЕЛЕЙ ---
  # Явно прописываем базовые пути, которые Rails терял из-за кастомных хелперов Хартла
  get    '/users',          to: 'users#index', as: 'all_users'
  get    '/users/:id',      to: 'users#show',  as: 'user_profile'
  # ------------------------------------------------

  # Расширенные маршруты для пользователей (Глава 14)
  # Оставляем только нужные экшены, чтобы вложенные ресурсы не ломали базовые GET-запросы
  resources :users, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
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

  # --- НОВАЯ ФИЧА: ПОЛИМОРФНЫЕ ЛАЙКИ ---
  # Маршруты для постановки и удаления лайков.
  # POST   /likes    => Метод create (поставить лайк)
  # DELETE /likes/:id => Метод destroy (убрать лайк)
  resources :likes,               only: [:create, :destroy]
  # -------------------------------------

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

  # --- НОВЫЙ КОД: МАРШРУТЫ ДЛЯ СИСТЕМЫ МОНЕТИЗАЦИИ И ПОКУПКИ АЧИВОК ---
  # Добавляет хелпер orders_path и связывает отправку формы покупки с OrdersController#create
  resources :orders, only: [:create]
  
  # --- ИСПРАВЛЕНИЕ ДЛЯ ССЫЛКИ ПОКУПКИ ---
  # Разрешаем создавать заказ через метод GET, чтобы тег details не блокировал отправку формы
  get '/orders', to: 'orders#create'

  # Пространство имен для приема вебхуков от платежных систем
  namespace :webhooks do
    post 'stripe', to: 'stripe#receive'
    
    # Вспомогательный роут для локальной симуляции успешной оплаты в WSL2 без интернета
    get 'stripe_mock_success', to: 'stripe#mock_success'
  end
  # --------------------------------------------------------------------
end