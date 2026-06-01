class CommentsController < ApplicationController
  before_action :logged_in_user # Эта ошибка подтверждает(опубликовать-ошибка), что в проекте Хартла нет стандартного метода authenticate_user! (он из библиотеки Devise).Использовали метод logged_in_user, который определен в приложении

  def create
    @user = User.find(params[:user_id])
    # Создаем комментарий: текущий юзер — автор, @user — владелец стены
    @wall_comment = @user.wall_comments.build(comment_params)
    @wall_comment.author = current_user 

    if @wall_comment.save
      # Используем одинаковый стиль всплывающих окон через flash
      flash[:success] = 'Сообщение успешно добавлено на стену!'
      
      # --- ИСПРАВЛЕНИЕ: Перенаправляем на наш гарантированный роут профиля ---
      redirect_to user_profile_path(@user)
    else
      flash[:danger] = 'Не удалось оставить сообщение. Текст слишком короткий или длинный.'
      
      # --- ИСПРАВЛЕНИЕ: Возвращаем на профиль со статусом see_other для Turbo ---
      redirect_to user_profile_path(@user), status: :see_other
    end
  end

  def destroy
    # --- ИСПРАВЛЕНИЕ: Переименовали в @wall_comment для единообразия ---
    @wall_comment = Comment.find(params[:id])
    @user = @wall_comment.wall_owner

    # Удалить может либо автор сообщения, либо владелец стены
    if current_user == @wall_comment.author || current_user == @user
      @wall_comment.destroy
      
      # --- ИСПРАВЛЕНИЕ: Используем наш гарантированный роут профиля ---
      flash[:success] = 'Сообщение удалено.'
      redirect_to user_profile_path(@user), status: :see_other
    else
      # --- ИСПРАВЛЕНИЕ: Используем наш гарантированный роут профиля ---
      flash[:danger] = 'У вас нет прав на удаление этого сообщения.'
      redirect_to user_profile_path(@user), status: :see_other
    end
  end

  private

  def comment_params
    # --- ВАЖНО: Поле в базе называется :body ---
    params.require(:comment).permit(:body)
  end
end