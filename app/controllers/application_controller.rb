class ApplicationController < ActionController::Base
  include Pagy::Backend # Подключаем пагинацию для всех контроллеров
  include SessionsHelper
  include UsersHelper

  # НОВАЯ ФИЧА: Обновляем время активности при каждом переходе по страницам
  before_action :update_last_seen_at, if: -> { logged_in? }

  private

    # Подтверждает вход пользователя
    def logged_in_user
      unless logged_in?
        flash[:danger] = "Пожалуйста, войдите."
        redirect_to login_url, status: :see_other
      end
    end

    # Метод для обновления времени последнего визита
    def update_last_seen_at
      current_user.update_column(:last_seen_at, Time.current)
    end
end