module Orders
  class CompleteJob < ApplicationJob
    queue_as :default

    def perform(order_id)
      order = Order.find(order_id)
      return unless order.completed?

      user = order.user
      badge_type = order.badge_product.badge_type

      # --- НОВЫЙ КОД: ИНТЕГРАЦИЯ С ВАШЕЙ СУЩЕСТВУЮЩЕЙ СИСТЕМОЙ АЧИВОК ---
      # Безопасно ищем ачивку в вашей старой таблице Badge по её имени или типу
      badge = Badge.find_by(badge_type: badge_type) || Badge.find_by(name: badge_type)

      if badge
        # Вызываем ваш родной метод из модели User для записи ачивки в базу данных
        user.award_badge(badge)
      end

      # --- НОВЫЙ КОД: ЖИВЫЕ ОБНОВЛЕНИЯ ИНТЕРФЕЙСА ЧЕРЕЗ TURBO STREAMS ---
      # 1. Добавляем иконку купленной ачивки в сетку #badges-list без перезагрузки страницы
      Turbo::StreamsChannel.broadcast_append_to(
        "user_#{user.id}_badges",
        target: "badges-list",
        partial: "badges/badge_icon", # Используем отдельный партиал для иконки
        locals: { badge: badge, badge_type: badge_type }
      )

      # 2. Динамически обновляем цифру счетчика наград на экране: Награды (X)
      Turbo::StreamsChannel.broadcast_update_to(
        "user_#{user.id}_badges",
        target: "badges-count",
        html: user.badges.count.to_s
      )

      # 3. Полностью удаляем текст "Пока нет наград", если это была самая первая ачивка пользователя
      Turbo::StreamsChannel.broadcast_remove_to(
        "user_#{user.id}_badges",
        target: "no-badges-text"
      )
    end
  end
end