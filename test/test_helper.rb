ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Запускать тесты в параллели (если ядер много)
  parallelize(workers: :number_of_processors)

  # Подключает все фикстуры (тестовые данные) из test/fixtures/*.yml
  fixtures :all

  # --- НАШИ ХЕЛПЕРЫ ДЛЯ ТЕСТОВ ---

  # Возвращает true, если тестовый пользователь вошел в систему
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Осуществляет вход под тестовым пользователем
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

# Этот кусок нужен для интеграционных тестов (в папке integration)
class ActionDispatch::IntegrationTest
  # Включает бэкенд и фронтенд хелперы Pagy для работы путей и верстки в тестах
  include Pagy::Backend
  include Pagy::Frontend

  # Входим в систему внутри интеграционного теста
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end