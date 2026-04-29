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
    
    # ГЛАВА 13: Загружаем микросообщения пользователя с пагинацией
    @microposts = @user.microposts.paginate(page: params[:page])
    
    # Создаем пустые объекты для форм, если пользователь в системе
    if logged_in?
      @note = current_user.notes.build 
      @micropost = current_user.microposts.build # Для будущей формы постов
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
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :bio )
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