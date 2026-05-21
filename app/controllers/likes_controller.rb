class LikesController < ApplicationController
  # Метод для постановки лайка
  def create
    @like = current_user.likes.build(like_params)
    @likeable = @like.likeable # Сохраняем объект (коммент), чтобы передать его в Turbo

    if @like.save
      respond_to do |format|
        # Rails ищет файл app/views/likes/create.turbo_stream.erb
        format.turbo_stream 
        format.html { redirect_back fallback_location: root_path }
      end
    end
  end

  # Метод для удаления лайка (Обновлен: теперь защищен от RecordNotFound)
  def destroy
    # Мы используем find_by вместо find, чтобы не было ошибки, если лайк уже удален
    @like = current_user.likes.find_by(id: params[:id])
    
    if @like
      @likeable = @like.likeable # Запоминаем, что мы лайкали, перед удалением
      @like.destroy

      respond_to do |format|
        # Rails ищет файл app/views/likes/destroy.turbo_stream.erb
        format.turbo_stream 
        format.html { redirect_back fallback_location: root_path }
      end
    else
      # Если лайка уже нет в базе, просто возвращаем пустой успешный ответ
      head :no_content
    end
  end

  private

  # Разрешаем только нужные поля для безопасности
  def like_params
    params.require(:like).permit(:likeable_id, :likeable_type)
  end
end