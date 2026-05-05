require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Извлекаем пользователя из фикстур
    @user = users(:lion)
    @note = notes(:orange)
  end

  # Тест 1: Попытка создать заметку без авторизации
  test "should redirect create when not logged in" do
    assert_no_difference 'Note.count' do
      post notes_path, params: { note: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  # Тест 2: Попытка удалить чужую заметку или без авторизации
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Note.count' do
      delete note_path(@note)
    end
    assert_redirected_to login_url
  end
end