class NotesController < ApplicationController
  # Ограничиваем доступ только для авторизованных пользователей
  before_action :logged_in_user, only: [:create, :destroy]

  # Создание заметки
  def create
    @note = current_user.notes.build(note_params)
    if @note.save
      flash[:success] = "Заметка создана!"
      redirect_to root_url
    else
      # ИСПРАВЛЕНИЕ ДЛЯ PAGY: Заменяем старый .paginate на pagy, 
      # чтобы при ошибке валидации страница не падала
      @micropost = current_user.microposts.build
      @pagy_microposts, @feed_items = pagy(current_user.feed, page_param: :microposts_page, items: 10)
      @pagy_notes, @notes = pagy(current_user.notes.order(created_at: :desc), page_param: :notes_page, items: 10)
      
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  # ➔ НАШЕ ИСПРАВЛЕНИЕ: Точный и проверенный метод удаления (destroy) ДО private!
  def destroy
    @note = current_user.notes.find_by(id: params[:id])
    if @note
      @note.destroy
      flash[:success] = "Заметка удалена"
    end
    # КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ ДЛЯ TURBO + MINITEST: 
    # Добавляем явный статус :see_other, чтобы тест корректно зафиксировал редирект
    redirect_back_or_to root_url, status: :see_other
  end

  private

    # Разрешенные параметры для заметки
    def note_params
      params.require(:note).permit(:content)
    end
end