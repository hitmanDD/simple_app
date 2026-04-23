class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]

  def index
  # Показываем по 2 пользователя на страницу, чтобы проверить пагинацию
  @users = User.paginate(page: params[:page], per_page: 20)
  end

  def show
    @user = User.find(params[:id])
    @notes = @user.notes
    if logged_in?
      @note = current_user.notes.build 
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params) 
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user 
    else
      render 'new', status: :unprocessable_entity 
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :bio )
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Пожалуйста, войдите в систему."
        redirect_to login_url, status: :see_other
      end
    end
end