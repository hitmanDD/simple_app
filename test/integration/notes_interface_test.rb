require "test_helper"

class NotesInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    # Извлекаем пользователя Lion через фикстуры
    @user = users(:lion)
  end

  test "note interface on home page" do
    log_in_as(@user)
    get root_path
    
    # Проверяем наличие сайдбара на странице
    assert_select 'aside.col-md-4'
    
    # Проверяем наличие текстового поля ввода заметки
    assert_select 'textarea'

    # ТЕСТ 1: Отправка пустой заметки
    assert_no_difference 'Note.count' do
      post notes_path, params: { note: { content: "" } }
    end

    # ТЕСТ 2: Отправка валидной заметки
    valid_content = "This is a valid note in the sidebar!"
    assert_difference 'Note.count', 1 do
      post notes_path, params: { note: { content: valid_content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    
    # Проверяем flash-уведомление
    assert_not flash.empty?
    assert_match "Заметка создана!", response.body

    # ТЕСТ 3: Удаление собственной заметки
    # Берем первую заметку пользователя Lion
    first_note = @user.notes.paginate(page: 1).first
    
    # Проверяем, что при удалении количество заметок уменьшается на 1
    # Мы тестируем сам запрос на удаление в БД
    assert_difference 'Note.count', -1 do
      delete note_path(first_note)
    end

    # ТЕСТ 4: Проверка отсутствия кнопок удаления на чужой странице
    get user_path(users(:vasya))
    assert_select 'a[href=?]', note_path(first_note), count: 0
  end
end