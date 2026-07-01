module PaymentGateways
  class BaseClient
    def create_payment(order:)
      raise NotImplementedError, "Реализуйте метод create_payment"
    end
  end
end

# app/services/payment_gateways/stripe_client.rb
module PaymentGateways
  class StripeClient < BaseClient
    def create_payment(order:)
      # Реализация API Stripe
      # response = Stripe::PaymentIntent.create(amount: ..., currency: ...)
      # OpenStruct.new(success?: true, provider_order_id: response.id, checkout_url: response.url)
    end
  end
end

# Фабрика для выбора нужного провайдера (зависит от валюты или настроек)
# app/services/payment_gateways/factory.rb
module PaymentGateways
  class Factory
    def self.client_for(currency)
      case currency.upcase
      when 'RUB' then PaymentGateways::YookassaClient.new
      else PaymentGateways::StripeClient.new
      end
    end
  end
end