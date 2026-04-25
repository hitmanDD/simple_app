class UsersController < ApplicationController
  # 1. Защита: запускаем проверку входа перед этими действиями
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  # 2. Добавили проверку на админа (только для удаления)
  before_action :admin_user,     only: :destroy

  # 2. Список всех пользователей (с пагинацией по 20 человек)
  def index
    @users = User.paginate(page: params[:page], per_page: 20)
  end

  # 3. Страница профиля (исправленная версия с проверкой на гостя)
  def show
    @user = User.find(params[:id])
    @notes = @user.notes # Достаем все заметки этого пользователя
    
    # Создаем пустую заметку ТОЛЬКО если пользователь залогинен
    if logged_in?
      @note = current_user.notes.build # Пустая модель для формы
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Мы убираем log_in @user, так как юзер должен сначала активировать почту
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # 3. Метод для удаления пользователя
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  private

    # Это защита: мы разрешаем записывать только эти 5 полей
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :bio )
    end

    # Предварительный фильтр для проверки авторизации
    def logged_in_user
      unless logged_in?
        store_location # Запоминаем, куда шел юзер
        flash[:danger] = "Пожалуйста, войдите в систему."
        redirect_to login_url, status: :see_other
      end
    end

    # Проверка: является ли текущий юзер админом
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end