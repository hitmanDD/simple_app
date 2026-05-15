class CommentsController < ApplicationController
  before_action :logged_in_user # Эта ошибка подтверждает(опубликовать-ошибка), что в проекте Хартла нет стандартного метода authenticate_user! (он из библиотеки Devise).Использовали метод logged_in_user, который определен в приложении

  def create
    @user = User.find(params[:user_id])
    # Создаем комментарий: текущий юзер — автор, @user — владелец стены
    @comment = @user.wall_comments.build(comment_params)
    @comment.author = current_user 

    if @comment.save
      redirect_to user_path(@user), notice: 'Сообщение успешно добавлено на стену!'
    else
      redirect_to user_path(@user), alert: 'Не удалось оставить сообщение. Текст слишком короткий или длинный.'
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @user = @comment.wall_owner

    # Удалить может либо автор сообщения, либо владелец стены
    if current_user == @comment.author || current_user == @user
      @comment.destroy
      redirect_to user_path(@user), notice: 'Сообщение удалено.'
    else
      redirect_to user_path(@user), alert: 'У вас нет прав на удаление этого сообщения.'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end