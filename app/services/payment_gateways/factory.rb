module PaymentGateways
  class Factory
    def self.client_for(currency)
      PaymentGateways::StripeClient.new
    end
  end
end