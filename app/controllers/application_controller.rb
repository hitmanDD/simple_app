class ApplicationController < ActionController::Base
  include SessionsHelper
  include UsersHelper
  private

    # Подтверждает вход пользователя
    def logged_in_user
      unless logged_in?
        flash[:danger] = "Пожалуйста, войдите."
        redirect_to login_url, status: :see_other
      end
    end
end

