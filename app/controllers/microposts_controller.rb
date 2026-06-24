class MicropostsController < ApplicationController
  # 1. Защита: только залогиненные пользователи могут создавать и удалять посты
  before_action :logged_in_user, only: [:create, :destroy]
  
  # 2. Безопасность: перед удалением проверяем, принадлежит ли пост текущему юзеру
  before_action :correct_user,   only: :destroy

  # Метод для создания нового поста
  def create
    # Создаем пост, связанный с текущим пользователем
    @micropost = current_user.microposts.build(micropost_params)
    
    respond_to do |format|
      if @micropost.save
        # === АВТОМАТИЧЕСКАЯ ВЫДАЧА АЧИВКИ ===
        # Находим ачивку "Первый шаг" по её ID
        #first_step_badge = Badge.find_by(id: 1)
        # Выдаем её пользователю (метод award_badge сам проверит, нет ли её уже)
        #current_user.award_badge(first_step_badge) if first_step_badge
        #логику в микропосте сделали и эту закомментил
        # =====================================

        flash.now[:success] = "Пост создан!" # НОВАЯ ФИЧА: .now нужен, чтобы флеш отобразился при Turbo-ответе
        format.html { redirect_to root_url }
        format.turbo_stream # НОВАЯ ФИЧА: Ищет файл create.turbo_stream.erb для магии без перезагрузки
      else
        # Если пост не прошел валидацию (например, пустой), подгружаем ленту снова для главной
        # ВАЖНО: Так как мы используем Pagy, переписываем пагинацию Хартла на Pagy
        @pagy, @feed_items = pagy(current_user.feed, items: 10)
        
        format.html { render 'static_pages/home', status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("micropost-form", partial: "microposts/form") } # НОВАЯ ФИЧА: Возвращает форму с ошибками без перезагрузки страницы
      end
    end
  end

  # Метод для удаления поста
  def destroy
    # Объект @micropost уже найден в фильтре correct_user
    @micropost.destroy
    flash[:success] = "Пост удален"
    # Возвращаем пользователя туда, где он был (в профиль или на главную)
    redirect_back_or_to(root_url, status: :see_other)
  end

  private

    # Разрешаем передавать только поле content
    def micropost_params
      params.require(:micropost).permit(:content)
    end

    # Предварительный фильтр: ищем пост только в сообщениях ТЕКУЩЕГО пользователя
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      # Если пост не найден (значит он чужой или его нет), отправляем на главную
      redirect_to root_url, status: :see_other if @micropost.nil?
    end
end