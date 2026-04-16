ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Запускать тесты в параллели (если ядер много)
  parallelize(workers: :number_of_processors)

  # Подключает все фикстуры (тестовые данные) из test/fixtures/*.yml
  fixtures :all

  # Здесь можно добавлять свои хелперы для тестов
end