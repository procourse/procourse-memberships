module DiscourseLeague
  class Gateways
    class PayPal

      def initialize(options = {})
        @options = options
      end

      def active_merchant
        gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(
          :login => SiteSetting.league_paypal_username,
          :password => SiteSetting.league_paypal_password,
          :signature => SiteSetting.league_paypal_signature
        )
      end

    end
  end
end