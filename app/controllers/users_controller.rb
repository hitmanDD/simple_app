class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params) 
    if @user.save
      flash[:success] = "Welcome to the Sample App!" # Добавляем это сообщение
      redirect_to @user 
    else
      render 'new', status: :unprocessable_entity 
    end
  end

  private

    # Это защита: мы разрешаем записывать только эти 4 поля
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end