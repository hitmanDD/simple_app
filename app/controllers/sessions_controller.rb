class SessionsController < ApplicationController

  def create
    # 1. Ищем пользователя в базе по email
    user = User.find_by(email: params[:session][:email].downcase)
    
    # 2. Проверяем: пользователь существует И пароль подходит
    if user && user.authenticate(params[:session][:password])
      # 3. НОВОЕ: Проверяем, активирован ли аккаунт
      if user.activated?
        log_in user
        # Если уже есть галочка "remember me", раскомментируем строку ниже:
        # params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        flash[:success] = "Добро пожаловать, #{user.name}!"
        redirect_to user
      else
        # Если не активирован — не пускаем и просим проверить почту
        message  = "Аккаунт не активирован. "
        message += "Проверьте почту для получения ссылки."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # Если данные неверны — показываем ошибку
      flash.now[:danger] = 'Неверный email или пароль'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in? # Метод должен быть в SessionsHelper
    redirect_to root_url, status: :see_other
  end
end