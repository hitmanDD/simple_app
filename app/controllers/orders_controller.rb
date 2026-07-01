class OrdersController < ApplicationController
  def create
    # Вызываем сервис, simple_command автоматически вернет объект команды
    command = Orders::CreateService.call(
      user: current_user,
      badge_type: params[:badge_type],
      currency: params[:currency]
    )

    if command.success?
      # FIX: Добавили status: :see_other (HTTP 303)
      # Это заставит Turbo на фронтенде проснуться и выполнить редирект на тестовый шлюз
      redirect_to command.result, allow_other_host: true, status: :see_other
    else
      # Возвращаем назад с ошибкой, если покупка невозможна
      # FIX: Добавили status: :unprocessable_entity для корректной подсветки ошибок в Turbo
      redirect_back fallback_location: root_path, 
                    alert: command.errors.full_messages.to_sentence, 
                    status: :unprocessable_entity
    end
  end
end