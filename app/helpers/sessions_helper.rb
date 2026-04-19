module SessionsHelper

  # Осуществляет вход данного пользователя
  def log_in(user)
    session[:user_id] = user.id
  end

  # Возвращает текущего залогиненного пользователя (если есть)
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # Возвращает true, если пользователь залогинен, иначе false
  def logged_in?
    !current_user.nil?
  end
end