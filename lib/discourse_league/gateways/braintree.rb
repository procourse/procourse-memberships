module ActiveMerchant
  module Billing
    class BraintreeBlueGateway

      def subscribe(credit_card_or_vault_id, options = {})
        return "subscribed"
      end

    end
  end
end

module DiscourseLeague
  class Gateways
    class Braintree

      def initialize(options = {})
        @options = options
      end

      def active_merchant
        gateway = ActiveMerchant::Billing::BraintreeGateway.new(
          :merchant_id => SiteSetting.league_braintree_merchant_id,
          :public_key => SiteSetting.league_braintree_public_key,
          :private_key => SiteSetting.league_braintree_private_key
        )
      end

    end
  end
end