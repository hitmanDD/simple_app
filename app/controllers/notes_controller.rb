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
      @feed_items = current_user.feed.paginate(page: params[:page])
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
    redirect_back_or_to root_url
  end

  private

    # Разрешенные параметры для заметки
    def note_params
      params.require(:note).permit(:content)
    end
end