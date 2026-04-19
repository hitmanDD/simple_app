class SessionsController < ApplicationController
def create
  # 1. Ищем пользователя в базе по email
    user = User.find_by(email: params[:session][:email].downcase)
  
  # 2. Проверяем: пользователь существует И пароль подходит
    if user && user.authenticate(params[:session][:password])
      log_in user
    # Если всё ок — позж здесь будет вход
      flash[:success] = "Добро пожаловать, #{user.name}!"
      redirect_to user
    else
      # Если данные неверны — показываем ошбку
      flash.now[:danger] = 'Неверный email или пароль'
      render 'new', status: :unprocessable_entity
    end

end

def destroy
  log_out # Этот метод должен быть в SessionsHelper
  redirect_to root_url, status: :see_other
end

end