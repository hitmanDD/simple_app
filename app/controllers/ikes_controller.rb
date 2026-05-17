class LikesController < ApplicationController
  # Метод для постановки лайка
  def create
    @like = current_user.likes.build(like_params)
    @like.save # Валидация в модели Like не даст создать дубль
    redirect_back fallback_location: root_path
  end

  # Метод для удаления лайка
  def destroy
    @like = current_user.likes.find(params[:id])
    @like.destroy
    redirect_back fallback_location: root_path
  end

  private

  def like_params
    params.require(:like).permit(:likeable_id, :likeable_type)
  end
end