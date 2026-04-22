class UsersController < ApplicationController
  # 1. Защита: запускаем проверку входа перед этими действиями
  before_action :logged_in_user, only: [:index, :edit, :update]

  # 2. Список всех пользователей (то, что мы только что обсуждали)
  def index
    @users = User.all
  end

  # 3. Страница профиля (исправленная версия с проверкой на гостя)
  def show
    @user = User.find(params[:id])
    @notes = @user.notes
    if logged_in?
      @note = current_user.notes.build 
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params) 
    if @user.save
      log_in @user # Сразу логиним после регистрации (по Хартлу)
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user 
    else
      render 'new', status: :unprocessable_entity 
    end
  end

  private

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
end