require "test_helper"

class NoteTest < ActiveSupport::TestCase
  # Метод setup выполняется перед каждым тестом
  def setup
    # Берём тестового пользователя lion из фикстур users.yml
    @user = users(:lion)
    # Создаем новую заметку, связанную с пользователем, но пока не сохраняем в БД
    @note = @user.notes.build(content: "Lorem ipsum")
  end

  # Тест 1: Исходная заметка должна быть валидной
  test "should be valid" do
    assert @note.valid?
  end

  # Тест 2: Заметка без user_id должна быть невалидной
  test "user id should be present" do
    @note.user_id = nil
    assert_not @note.valid?
  end

  # Тест 3: Пустая заметка должна быть невалидной
  test "content should be present" do
    @note.content = "   "
    assert_not @note.valid?
  end

  # Тест 4: Заметка длиннее 140 символов должна быть невалидной
  test "content should be at most 140 characters" do
    @note.content = "a" * 141
    assert_not @note.valid?
  end

  # Тест 5: Проверка сортировки default_scope (сначала самые новые)
  test "order should be most recent first" do
    assert_equal notes(:most_recent), Note.first
  end
end