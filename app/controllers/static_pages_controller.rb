class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # --- ВАШ СТАРЫЙ ВАРИАНТ (Если у вас была только форма для заметок) ---
      # @note = current_user.notes.build if logged_in?

      # --- НОВЫЙ ВАРИАНТ ПО КНИГЕ ---
      # Создаем пустой объект микросообщения для формы в сайдбаре (Глава 13)
      @micropost  = current_user.microposts.build
      
      # Получаем ленту новостей с пагинацией для текущего юзера (Глава 14)
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end