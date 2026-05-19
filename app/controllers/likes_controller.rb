class LikesController < ApplicationController
  # Метод для постановки лайка
  def create
    @like = current_user.likes.build(like_params)
    @likeable = @like.likeable # Сохраняем объект (коммент), чтобы передать его в Turbo

    if @like.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        # Rails ищет файл app/views/likes/create.turbo_stream.erb
        format.turbo_stream 
      end
    end
  end

  # Метод для удаления лайка
  def destroy
    @like = current_user.likes.find(params[:id])
    @likeable = @like.likeable # Запоминаем, что мы лайкали, перед удалением
    @like.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      # Rails ищет файл app/views/likes/destroy.turbo_stream.erb
      format.turbo_stream 
    end
  end

  private

  # Разрешаем только нужные поля для безопасности
  def like_params
    params.require(:like).permit(:likeable_id, :likeable_type)
  end
end