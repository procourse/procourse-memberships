require_relative '../billing/gateways'
require "paypal-sdk-rest"
include PayPal::SDK::REST
include PayPal::SDK::Core::Logging

module DiscourseLeague
  class Gateways
    class PayPalAPIGateway

      def initialize(options = {})
          environment = PayPal::SandboxEnvironment.new(SiteSetting.league_paypal_api_id, SiteSetting.league_paypal_api_secret)
          client = PayPal::PayPalHttpClient.new(environment)
      end

      def purchase(user_id, product, options = {})
        customer = self.customer(user_id)
        payment = {
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
        }


        request = PaymentCreateRequest.new
        request.request_body(payment);

        begin
          response = client.execute(request)
          puts response.status_code
          puts response.result
          return {:success => true, :response => response}
        rescue BraintreeHttp::HttpError => e
          puts e.status_code
          puts e.result
          return {:message => e}
        end

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
