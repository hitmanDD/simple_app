class MicropostsController < ApplicationController
  # 1. Защита: только залогиненные пользователи могут создавать и удалять посты
  before_action :logged_in_user, only: [:create, :destroy]
  
  # 2. Безопасность: перед удалением проверяем, принадлежит ли пост текущему юзеру
  before_action :correct_user,   only: :destroy

  # Метод для создания нового поста
  def create
    # Создаем пост, связанный с текущим пользователем
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Пост создан!"
      redirect_to root_url
    else
      # Если пост не прошел валидацию (например, пустой), подгружаем ленту снова для главной
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
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