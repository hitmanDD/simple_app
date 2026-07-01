module Orders
  class CreateService
    prepend SimpleCommand # Ипользуем гем simple_command для удобной обработки ошибок

    def initialize(user:, badge_type:, currency:)
      @user = user
      @badge_type = badge_type
      @currency = currency
    end

    def call
      product = BadgeProduct.find_by!(badge_type: @badge_type, currency: @currency, active: true)
      
      # Защита: нельзя купить ачивку, которая уже есть
      # ИСПРАВЛЕНИЕ: приводим к безопасному массиву строк, чтобы не зависеть от структуры старой таблицы
      owned_types = @user.badges.map { |b| b.respond_to?(:badge_type) ? b.badge_type : b.name }
      if owned_types.include?(@badge_type)
        errors.add(:base, "Вы уже владеете этой ачивкой")
        return nil
      end

      Order.transaction do
        order = @user.orders.create!(
          badge_product: product,
          amount: product.price,
          currency: product.currency,
          payment_provider: provider_name
        )

        gateway = PaymentGateways::Factory.client_for(@currency)
        result = gateway.create_payment(order: order)

        if result.success?
          order.update!(provider_order_id: result.provider_order_id)
          return result.checkout_url # Возвращаем линк на оплату для редиректа пользователя
        else
          errors.add(:payment, "Ошибка инициализации платежа шлюзом")
          raise ActiveRecord::Rollback
        end
      end
    rescue ActiveRecord::RecordNotFound
      errors.add(:product, "Продукт не найден или недоступен")
      return nil # Фиксируем ошибку для simple_command
    end

    private

    def provider_name
      @currency.upcase == 'RUB' ? 'yookassa' : 'stripe'
    end
  end
end