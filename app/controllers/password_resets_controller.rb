class PasswordResetsController < ApplicationController
  # Фильтры, которые выполняются перед редактированием и обновлением пароля
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
    # Просто отображает форму ввода email
  end

  def create
    # Ищем пользователя по email
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # Создаем токен сброса и сохраняем его в базу
      @user.create_reset_digest
      # Отправляем письмо со ссылкой
      @user.send_password_reset_email
      flash[:info] = "На вашу почту отправлены инструкции по сбросу пароля"
      redirect_to root_url
    else
      # Если email не найден в базе
      flash.now[:danger] = "Email адрес не найден"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    # Эта страница просто отображает форму ввода нового пароля
  end

  def update
    if params[:user][:password].empty?                  
      # Случай 1: если пользователь отправил пустой пароль
      @user.errors.add(:password, "не может быть пустым")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)                     
      # Случай 2: успешное обновление пароля
      @user.forget # Сбрасываем сессии (токены запоминания)
      log_in @user # Автоматически входим в систему
      @user.update_attribute(:reset_digest, nil) # Удаляем токен сброса, он больше не нужен
      flash[:success] = "Пароль был успешно изменен."
      redirect_to @user
    else
      # Случай 3: ошибки валидации (например, пароль слишком короткий)
      render 'edit', status: :unprocessable_entity
    end
  end

  private

    # Разрешаем только нужные поля для обновления
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Находит пользователя по email из ссылки
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Проверяет: существует ли юзер, активирован ли он и совпадает ли токен
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Проверяет, не прошло ли более 2 часов с момента отправки письма
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Срок действия ссылки истек."
        redirect_to new_password_reset_url
      end
    end
end