class StaticPagesController < ApplicationController
def home
    if logged_in?
      # Создаем пустой объект микросообщения для формы в сайдбаре (Глава 13)
      @micropost  = current_user.microposts.build
      
      # 1. СЛУЖЕБНАЯ СОЦИАЛЬНАЯ ЛЕНТА (Микропосты по книге Хартла)
      # Выводим по 10 штук, а page_param предотвращает конфликт с пагинацией заметок
      @pagy_microposts, @feed_items = pagy(current_user.feed, page_param: :microposts_page, items: 10)
      
      # 2. ВАШ ПРИВАТНЫЙ БЛОКНОТ (Личные заметки — только текущего пользователя)
      # Выводим строго личные заметки по 10 штук
      @pagy_notes, @notes = pagy(current_user.notes.order(created_at: :desc), page_param: :notes_page, items: 10)
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end