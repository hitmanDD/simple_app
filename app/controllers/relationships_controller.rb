class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    # БЫЛО: user = User.find(params[:followed_id])
    # СТАЛО: Заменили локальную переменную 'user' на переменную экземпляра '@user'.
    # Это критично, так как она понадобится нам внутри файлов Turbo Stream (.erb).
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    
    # БЫЛО: redirect_to user
    # СТАЛО: Добавили блок respond_to для поддержки Turbo Streams
    respond_to do |format|
      # Если браузер не поддерживает JS/Turbo, сработает обычный редирект (как и было):
      format.html { redirect_to @user }
      # Если пришел асинхронный запрос от Turbo, Rails пойдет искать 
      # файл app/views/relationships/create.turbo_stream.erb:
      format.turbo_stream
    end
  end

  def destroy
    # БЫЛО: user = Relationship.find(params[:id]).followed
    # СТАЛО: Опять же, меняем на '@user' для доступности во вьюхах Turbo Stream.
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    
    # БЫЛО: redirect_to user, status: :see_other
    # СТАЛО: Добавили блок respond_to
    respond_to do |format|
      # Обычный редирект для классических браузеров:
      format.html { redirect_to @user, status: :see_other }
      # Ответ для Turbo-запроса (будет искать файл destroy.turbo_stream.erb):
      format.turbo_stream
    end
  end
end