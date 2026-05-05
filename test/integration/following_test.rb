require "test_helper"

class FollowingTest < ActionDispatch::IntegrationTest
  # Метод setup выполняется перед каждым тестом
  def setup
    # Извлекаем пользователя Lion из фикстур users.yml (строчными буквами)
    @user  = users(:lion)
    
    # Извлекаем другого пользователя Vasya из фикстур users.yml для проверок
    @other = users(:vasya)
    
    # Авторизуем пользователя @user в тестовой сессии
    log_in_as(@user)
  end

  # Тест проверяет корректность отображения страницы "Подписки" (Following)
  test "following page" do
    # Переходим на страницу подписок нашего пользователя
    get following_user_path(@user)
    
    # Проверяем, что список подписок не пустой (у пользователя есть подписки в фикстурах)
    assert_not @user.following.empty?
    
    # Проверяем, что общее количество подписок отображается на странице
    assert_match @user.following.count.to_s, response.body
    
    # Перебираем всех пользователей из списка подписок
    @user.following.each do |user|
      # Проверяем, что на странице есть ссылка на профиль каждого из них
      assert_select "a[href=?]", user_path(user)
    end
  end

  # Тест проверяет корректность отображения страницы "Подписчики" (Followers)
  test "followers page" do
    # Переходим на страницу подписчиков нашего пользователя
    get followers_user_path(@user)
    
    # Проверяем, что список подписчиков не пустой
    assert_not @user.followers.empty?
    
    # Проверяем, что общее количество подписчиков отображается на странице
    assert_match @user.followers.count.to_s, response.body
    
    # Перебираем всех пользователей из списка подписчиков
    @user.followers.each do |user|
      # Проверяем, что на странице есть ссылка на профиль каждого подписчика
      assert_select "a[href=?]", user_path(user)
    end
  end
end