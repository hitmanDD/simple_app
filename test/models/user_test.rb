require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    # Создаем тестового пользователя в оперативной памяти (не в базе)
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "password", password_confirmation: "password",
                     bio: "Привет, я новый пользователь!")
  end

  # Тест: Пользователь должен быть валидным (проверка базы)
  test "should be valid" do
    assert @user.valid?
  end

  # Твой новый тест для BIO
  test "bio should not be too long" do
    @user.bio = "a" * 501 # Делаем строку на 1 символ длиннее лимита
    assert_not @user.valid?
  end
end