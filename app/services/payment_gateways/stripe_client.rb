module PaymentGateways
  class StripeClient
    def create_payment(order:)
      fake_provider_id = "ch_test_#{SecureRandom.hex(6)}"
      fake_checkout_url = "/webhooks/stripe_mock_success?order_id=#{order.id}&provider_id=#{fake_provider_id}"

      OpenStruct.new(
        success?: true, 
        provider_order_id: fake_provider_id, 
        checkout_url: fake_checkout_url
      )
    end
  end
end