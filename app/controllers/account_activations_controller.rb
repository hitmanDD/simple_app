class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    # Проверяем: юзер есть, он не активирован и токен подходит
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate # Метод, который мы сейчас добавим в модель
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end