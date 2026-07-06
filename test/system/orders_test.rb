require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one) # Предполагаем, что у вас есть фикстуры пользователей
    # Если используется Warden/Devise для авторизации:
    # login_as(@user, scope: :user)
  end

  test "successful badge purchase redirects via stripe mock to profile" do
    # 1. Переходим на страницу, где находится форма покупки (например, профиль)
    visit user_path(@user)

    # 2. Кликаем по кнопке оплаты
    
    click_on "Оплатить"

    # 3. Проверяем финишную точку
    # Так как мок мгновенно редиректит на профиль, мы должны оказаться снова здесь
    assert_current_path user_path(@user)

    # 4. Проверяем, что заказ реально создался в базе данных
    assert_equal 1, @user.orders.count
  end
end