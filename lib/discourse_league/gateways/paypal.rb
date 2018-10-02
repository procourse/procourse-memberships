require_relative '../billing/gateways'
require "paypal-sdk-rest"
include PayPal::V1::Payments
include PayPal::V1::BillingAgreements

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
          response["result"]["gateway"] = "paypal"
          return {:response => response.result}
        rescue BraintreeHttp::HttpError => e
          puts e.status_code
          puts e.result
          return {:success => false, :message => e}
        end
      end

      def execute(user_id, product, payment_id, payer_id)
          if product[:recurring] == true
              request = AgreementExecuteRequest.new(payment_id)
          else
              request = PaymentExecuteRequest.new(payment_id)
              request.request_body({
                  "payer_id": payer_id
              })
          end

          begin
            response = @@client.execute(request)
            puts response.status_code
            puts response.result

            paypal = {
                email: response.result.payer.payer_info.email,
                first_name: response.result.payer.payer_info.first_name,
                last_name: response.result.payer.payer_info.last_name,
                payload: response.result
            }

            league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => {payment_id: payment_id, payer_id: payer_id})
            league_gateway.store_token
            if product[:recurring]
                subscription = response.result
                billing_begin_date = Date.parse response.result.start_date
                billing_interval = subscription.plan.payment_definitions[0].frequency_interval.to_i #assumed months
                
                if subscription.plan.payment_definitions[1]
                    trial_interval = subscription.plan.payment_definitions[1].frequency_interval.to_i  #assumed days
                else
                    trial_interval = 0
                end
                billing_end_date = billing_begin_date + trial_interval.days + billing_interval.months
                league_gateway.store_subscription(subscription.id, billing_end_date)
            else
                transaction = response.result.transactions[0].related_resources[0].sale
                league_gateway.store_transaction(transaction.id, transaction.amount.total, Time.now(), nil, paypal)
            end
            response.result.success = true
            return {:response => response.result}
          rescue BraintreeHttp::HttpError => e
            puts e.status_code
            puts e.result
            return {:success => false, :message => e}
          end
      end

      def subscribe(user_id, product, nonce, options = {})
          request = AgreementCreateRequest.new
          time = Time.now + 60*60*27
          request.request_body(
              :name => product[:name],
              :description => "Description: " + product[:name],
              :start_date => time.iso8601,
              :payer => {
                  :payment_method => "paypal"
              },
              :plan => {
                  :id => product[:paypal_plan_id]
              }
          )
          
          begin
            response = @@client.execute(request)
            puts response.status_code
            puts response.result

            response["result"]["success"] = true
            response["result"]["gateway"] = "paypal"
            
            response.result
            return {:response => response.result}
          rescue BraintreeHttp::HttpError => e
            puts e.status_code
            puts e.result
            return {:success => false, :message => e}
          end
      end

      def unsubscribe(subscription_id, options = {})
          request = AgreementCancelRequest.new(subscription_id)
          request.request_body(:note => "Canceling the subscription.")

          begin
            response = @@client.execute(request)
            puts response
            response.result = {"success": true}
            return {:response => response.result}
          rescue BraintreeHttp::HttpError => e
            puts e.status_code
            puts e.result
            response.message = e
            return response
          end
      end

      def update_payment(user_id, product, subscription_id, nonce, options = {})

      end

      def customer(user_id)

      end

      def parse_webhook(request)
        response = validate_IPN_notification(request.raw_post)
        case response
            when "VERIFIED"
                puts request.params
            when "INVALID"
                puts request.params
                if request.params.key?("recurring_payment")
                    binding.pry
                    Jobs.enqueue(:subscription_charged_successfully, {
                        id: request.params[:recurring_payment_id] , 
                        options: {
                          paid_through: request.params[:next_payment_date],
                          transaction_id: request.params[:txn_id],
                          transaction_amount: request.params[:mc_gross],
                          transaction_date: request.params[:payment_date],
                          paypal_details: {
                              email: request.params[:payer_email],
                              first_name: request.params[:first_name],
                              last_name: request.params[:last_name],
                              image: nil
                          }
                        }
                      })
                elsif request.params.key?("recurring_payment_failed")
                    Jobs.enqueue(:subscription_charged_unsuccessfully, {id: response.params[:txn_id]})
                end
        else
            return response
        end
      end
      private
        def validate_IPN_notification(raw)
            if SiteSetting.league_go_live == false
                sandbox = "sandbox."
            end
            uri = URI.parse("https://ipnpb.#{sandbox}paypal.com/cgi-bin/webscr?cmd=_notify-validate")
            puts uri
            http = Net::HTTP.new(uri.host, uri.port)
            http.open_timeout = 60
            http.read_timeout = 60
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.use_ssl = true
            response = http.post(uri.request_uri, raw,
                                'Content-Length' => "#{raw.size}",
                                'User-Agent' => "My custom user agent"
                            ).body
        end
    end
  end
end
