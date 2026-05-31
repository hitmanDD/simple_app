class CommentsController < ApplicationController
  before_action :logged_in_user # Эта ошибка подтверждает(опубликовать-ошибка), что в проекте Хартла нет стандартного метода authenticate_user! (он из библиотеки Devise).Использовали метод logged_in_user, который определен в приложении

  def create
    @user = User.find(params[:user_id])
    # Создаем комментарий: текущий юзер — автор, @user — владелец стены
    # --- ИСПРАВЛЕНИЕ: Переименовали в @wall_comment для точного соответствия нашей вьюхе профиля ---
    @wall_comment = @user.wall_comments.build(comment_params)
    @wall_comment.author = current_user 

    if @wall_comment.save
      redirect_to user_path(@user), notice: 'Сообщение успешно добавлено на стену!'
    else
      # --- ИСПРАВЛЕНИЕ: Если сохранение не удалось, мы делаем render вместо redirect_to. ---
      # Это позволяет показать конкретные ошибки валидации прямо на странице, не стирая текст.
      # Для этого инициализируем переменные профиля и пагинацию Pagy, чтобы страница не падала:
      @notes = @user.notes
      @microposts = @user.microposts.paginate(page: params[:page])
      @pagy_comments, @wall_comments = pagy(@user.wall_comments.order(created_at: :desc), page_param: :page_comments)
      
      flash.now[:danger] = 'Не удалось оставить сообщение. Текст слишком короткий или длинный.'
      render 'users/show', status: :unprocessable_entity
    end
  end

  def destroy
    # --- ИСПРАВЛЕНИЕ: Переименовали в @wall_comment для единообразия ---
    @wall_comment = Comment.find(params[:id])
    @user = @wall_comment.wall_owner

    # Удалить может либо автор сообщения, либо владелец стены
    if current_user == @wall_comment.author || current_user == @user
      @wall_comment.destroy
      redirect_to user_path(@user), notice: 'Сообщение удалено.', status: :see_other
    else
      redirect_to user_path(@user), alert: 'У вас нет прав на удаление этого сообщения.', status: :see_other
    end
  end

  private

  def comment_params
    # --- ВАЖНО: Поле в базе называется :body ---
    params.require(:comment).permit(:body)
  end
end