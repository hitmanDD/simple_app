require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  # Метод setup выполняется перед каждым тестом
  def setup
    # Очищаем массив отправленных писем, чтобы тесты не мешали друг другу
    ActionMailer::Base.deliveries.clear
  end

  # Тест проверяет поведение при отправке невалидных данных регистрации
  test "invalid signup information" do
    # Переходим на страницу регистрации
    get signup_path
    
    # Проверяем, что количество пользователей в БД НЕ изменилось
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    
    # Проверяем, что нас вернули на страницу регистрации
    assert_template 'users/new'
  end

  # Тест проверяет успешную регистрацию с последующей активацией через email
  test "valid signup information with account activation" do
    # Переходим на страницу регистрации
    get signup_path
    
    # Проверяем, что количество пользователей увеличилось ровно на 1
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    
    # Проверяем, что было отправлено ровно 1 письмо активации
    assert_equal 1, ActionMailer::Base.deliveries.size
    
    # Извлекаем созданного пользователя из контроллера для дальнейших тестов
    user = assigns(:user)
    
    # Проверяем, что новый пользователь пока НЕ активирован
    assert_not user.activated?
    
    # Пытаемся войти под неактивированным пользователем
    log_in_as(user)
    
    # Проверяем, что вход в систему НЕ был осуществлен
    assert_not is_logged_in?
    
    # Пытаемся активировать аккаунт с невалидным токеном
    get edit_account_activation_path("invalid token", email: user.email)
    
    # Проверяем, что вход по-прежнему НЕ выполнен
    assert_not is_logged_in?
    
    # Пытаемся активировать аккаунт с валидным токеном, но неверным email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    
    # Проверяем, что вход всё ещё НЕ выполнен
    assert_not is_logged_in?
    
    # Выполняем переход по ссылке активации с верными параметрами
    get edit_account_activation_path(user.activation_token, email: user.email)
    
    # Перезагружаем данные пользователя из БД и проверяем, что он теперь активирован
    assert user.reload.activated?
    
    # Переходим на страницу редиректа после успешной активации
    follow_redirect!
    
    # Проверяем, что нас перенаправило на страницу профиля пользователя
    assert_template 'users/show'
    
    # Проверяем, что пользователь теперь успешно авторизован в системе
    assert is_logged_in?
  end
end