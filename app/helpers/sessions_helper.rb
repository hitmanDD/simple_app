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
  # Добавляем этот метод для выхода:
  def log_out
    forget(current_user) # Если будешь делать "запомнить меня", пригодится
    reset_session
    @current_user = nil
  end
  
  # Пока просто заглушка для forget, если метода еще нет
  def forget(user)
    # Здесь позже будет удаление cookies
  end

  # Перенаправляет к сохраненному адресу или по умолчанию
  def redirect_back_or(default)
  redirect_to(session[:forwarding_url] || default, status: :see_other)
  session.delete(:forwarding_url)
  end

  # Запоминает URL, по которому пытались перейти
  def store_location
  session[:forwarding_url] = request.original_url if request.get?
  end
  
end
  