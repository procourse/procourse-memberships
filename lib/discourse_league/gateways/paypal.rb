require_relative '../billing/gateways'
require "paypal-sdk-rest"

module DiscourseLeague
  class Gateways
    class PayPalGateway

      def initialize(options = {})
          # environment = PayPal::SandboxEnvironment.new(SiteSetting.league_paypal_api_id, SiteSetting.league_paypal_api_secret)
          # client = PayPal::PayPalHttpClient.new(environment)
          PayPal::SDK::REST.set_config(
            :mode => "sandbox", # "sandbox" or "live"
            :client_id => SiteSetting.league_paypal_api_id,
            :client_secret => SiteSetting.league_paypal_api_secret)
      end

      def purchase(user_id, product, options = {})
        customer = self.customer(user_id)

        payment = PayPal::SDK::REST::Payment.new({
          :intent => "sale",
          :transactions => [
            :amount => {
              :currency => SiteSetting.league_currency,
              :total => "10"
            }
          ],
          :redirect_urls => {
            :cancel_url => request.domain + "/",
            :return_url => request.domain + "/checkout/paypal_api/success"
          },
          :payer => {
            :payment_method => "paypal"
          }
        })
        # request.request_body(payment);
        if payment.create
          response = payment.id     # Payment Id
        else
          response = payment.error  # Error Hash
        end
        return {:message => response}

      end

      def execute()

      end

      def subscribe(user_id, product, nonce, options = {})

      end

      def unsubscribe(subscription_id, options = {})

      end

      def update_payment(user_id, product, subscription_id, nonce, options = {})

      end

      def customer(user_id)

      end

      def parse_webhook(request)

      end

    end
  end
end
