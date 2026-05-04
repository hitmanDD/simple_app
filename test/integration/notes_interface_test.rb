require "test_helper"

class NotesInterfaceTest < ActionDispatch::IntegrationTest
  # Метод setup выполняется перед каждым тестом
  def setup
    # Берём пользователя lion из фикстур для авторизации
    @user = users(:lion)
  end

  # Основной тест интерфейса заметок на главной странице
  test "note interface on home page" do
    # 1. Авторизуемся под пользователем Lion
    log_in_as(@user)
    
    # 2. Переходим на главную страницу
    get root_path
    
    # 3. Проверяем, что на странице есть сайдбар
    assert_select 'div.sidebar'
    
    # 4. Проверяем наличие формы для создания заметок
    assert_select 'form[action="/notes"]'

    # ТЕСТ 1: Отправка пустой (невалидной) заметки
    assert_no_difference 'Note.count' do
      post notes_path, params: { note: { content: "" } }
    end
    # Проверяем, что появились сообщения об ошибках валидации
    assert_select 'div#error_explanation'

    # ТЕСТ 2: Отправка валидной заметки
    valid_content = "This is a valid note in the sidebar!"
    assert_difference 'Note.count', 1 do
      post notes_path, params: { note: { content: valid_content } }
    end
    # Проверяем, что после создания происходит редирект на главную страницу
    assert_redirected_to root_url
    follow_redirect!
    # Проверяем, что текст заметки появился в теле ответа страницы
    assert_match valid_content, response.body

    # ТЕСТ 3: Удаление собственной заметки
    assert_select 'a', text: 'delete'
    # Берем первую заметку пользователя
    first_note = @user.notes.paginate(page: 1).first
    # Проверяем, что после удаления количество заметок в БД уменьшилось на 1
    assert_difference 'Note.count', -1 do
      delete note_path(first_note)
    end

    # ТЕСТ 4: Проверка отсутствия кнопок удаления на чужой странице
    # Переходим в профиль пользователя Vasya
    get user_path(users(:vasya))
    # Проверяем, что ссылок 'delete' на чужой странице нет
    assert_select 'a', text: 'delete', count: 0
  end
end