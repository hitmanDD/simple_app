class UsersController < ApplicationController
  # Защита: добавили :following и :followers в список действий, требующих входа
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  # Проверка прав администратора для удаления
  before_action :admin_user,     only: :destroy

  # Список всех пользователей (пагинация по 20 человек)
  def index
    @users = User.paginate(page: params[:page], per_page: 20)
  end

  # Страница профиля пользователя
  def show
    @user = User.find(params[:id])
    @notes = @user.notes # Загружаем заметки
    
    # ИСПРАВЛЕНО ДЛЯ PAGY: Загружаем микросообщения пользователя с пагинацией Pagy.
    # Параметр :page_microposts изолирует клики от пагинации комментариев стены.
    @pagy_microposts, @microposts = pagy(@user.microposts.order(created_at: :desc), page_param: :page_microposts, items: 10)
    
    # --- НОВЫЙ БЛОК: ИНТЕГРАЦИЯ PAGY ДЛЯ СТЕНЫ ПРОФИЛЯ ---
    # Загружаем записи на стене с пагинацией Pagy от новых к старым. Переменная :page_comments изолирует клики по страницам стены.
    @pagy_comments, @wall_comments = pagy(@user.wall_comments.order(created_at: :desc), page_param: :page_comments)
    # --------------------------------------------------------------
    
    # Создаем пустые объекты для форм, если пользователь в системе
    if logged_in?
      @note = current_user.notes.build 
      @micropost = current_user.microposts.build # Для будущей формы постов
      
      # --- НОВАЯ СТРОКА: ИНИЦИАЛИЗАЦИЯ ФОРМЫ СТЕНЫ ---
      # Создаем пустой комментарий для стены, привязанный к текущему владельцу профиля (@user)
      @wall_comment = @user.wall_comments.build
    end
  end

  # --- НОВЫЕ МЕТОДЫ: РЕДАКТИРОВАНИЕ И ОБНОВЛЕНИЕ ---

  # Показываем форму редактирования профиля (настройки)
  def edit
    @user = User.find(params[:id])
  end

  # Сохраняем изменения профиля (включая аватарку)
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Профиль обновлен!"
      redirect_to @user
    else
      # Если валидация не прошла, возвращаем форму редактирования
      render 'edit', status: :unprocessable_entity
    end
  end

  # ГЛАВА 14: Страница со списком тех, на кого подписан пользователь
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow' # Используем общий шаблон для списков
  end

  # ГЛАВА 14: Страница со списком подписчиков пользователя
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow' # Используем тот же общий шаблон
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Отправка письма для активации аккаунта
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # Удаление пользователя (только для админов)
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  private

    # Строгие параметры (Strong Parameters)
    def user_params
      # Параметр :avatar разрешен для безопасного приема файлов
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :bio, :avatar)
    end

    # Проверка, залогинен ли пользователь
    def logged_in_user
      unless logged_in?
        store_location # Запоминаем текущую страницу для возврата после входа
        flash[:danger] = "Пожалуйста, войдите в систему."
        redirect_to login_url, status: :see_other
      end
    end

    # Проверка на права администратора
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end