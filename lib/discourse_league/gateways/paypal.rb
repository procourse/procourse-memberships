require_relative '../billing/gateways'
require "paypal-sdk-rest"
include PayPal::V1::Payments

module DiscourseLeague
  class Gateways
    class PayPalGateway

      def initialize(options = {})
          if SiteSetting.league_go_live?
              @@environment = PayPal::LiveEnvironment.new(SiteSetting.league_paypal_api_id, SiteSetting.league_paypal_api_secret)
          else
              @@environment = PayPal::SandboxEnvironment.new(SiteSetting.league_paypal_api_id, SiteSetting.league_paypal_api_secret)
          end
          @@client = PayPal::PayPalHttpClient.new(@@environment)

      end

      def purchase(user_id, product, nonce, options = {})
        request = PaymentCreateRequest.new
        request.request_body({
          :intent =>  "sale",
          :payer =>  {
            :payment_method =>  "paypal" },
          :redirect_urls => {
            :return_url => "#{Discourse.base_url}/league/l/#{product[:id]}",
            :cancel_url => "#{Discourse.base_url}" },
          :transactions =>  [{
            :item_list => {
              :items => [{
                :name => product[:name],
                :sku => product[:id],
                :price => product[:initial_payment],
                :currency => SiteSetting.league_currency,
                :quantity => 1 }]},
            :amount =>  {
              :total =>  product[:initial_payment],
              :currency =>  SiteSetting.league_currency }
          }]})

        begin
          response = @@client.execute(request)
          puts response.status_code
          puts response.result

          response["result"]["success"] = true
          return {:response => response.result}
        rescue BraintreeHttp::HttpError => e
          puts e.status_code
          puts e.result
          return {:success => false, :message => e}
        end
      end

      def execute(user_id, product, payment_id, payer_id)
          request = PaymentExecuteRequest.new(payment_id)
          request.request_body({
              "payer_id": payer_id
          })

          begin
            response = @@client.execute(request)
            puts response.status_code
            puts response.result

            transaction = response.result.transactions[0].related_resources[0].sale

            paypal = {
                email: response.result.payer.payer_info.email,
                first_name: response.result.payer.payer_info.first_name,
                last_name: response.result.payer.payer_info.last_name,
                payload: response.result
            }

            league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => {payment_id: payment_id, payer_id: payer_id})
            league_gateway.store_token
            league_gateway.store_transaction(transaction.id, transaction.amount.total, Time.now(), nil, paypal)
            response.result.success = true
            return {:response => response.result}
          rescue BraintreeHttp::HttpError => e
            puts e.status_code
            puts e.result
            return {:success => false, :message => e}
          end
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
