module DiscourseLeague
  module Gateways
    class Braintree

      def initialize(options = {})
        ActiveMerchant::Billing::BraintreeGateway.new(
          :merchant_id => ,
          :public_key => ,
          :private_key => 
        )
      end

    end
  end
end