require_relative '../billing/gateways'
require "braintree"

module DiscourseLeague
  class Gateways
    class BraintreeGateway

      def initialize(options = {})
        Braintree::Configuration.merchant_id = SiteSetting.league_braintree_merchant_id
        Braintree::Configuration.public_key = SiteSetting.league_braintree_public_key
        Braintree::Configuration.private_key = SiteSetting.league_braintree_private_key
        Braintree::Configuration.environment = (DiscourseLeague::Billing::Gateways.mode == :test ? :sandbox : :production).to_sym

        @client_token = Braintree::ClientToken.generate
      end

      def client_token
        @client_token
      end

      def purchase(user_id, product, nonce, options = {})
        customer = self.customer(user_id)
        response = Braintree::Transaction.sale(
          :amount => product[:initial_payment].to_i,
          :payment_method_nonce => nonce,
          :options => {
            :store_in_vault => true,
            :submit_for_settlement => true
          },
          :customer_id => customer.id,
          :recurring => false
        )
        if response.success?
          league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => response.transaction.credit_card_details.token)
          league_gateway.store_token

          credit_card = {
            name: response.transaction.credit_card_details.cardholder_name,
            last_4: response.transaction.credit_card_details.last_4,
            expiration: response.transaction.credit_card_details.expiration_date,
            brand: response.transaction.credit_card_details.card_type,
            image: response.transaction.credit_card_details.image_url
          }
          paypal = {
            email: response.transaction.paypal_details.payer_email,
            first_name: response.transaction.paypal_details.payer_first_name,
            last_name: response.transaction.paypal_details.payer_last_name,
            image: response.transaction.paypal_details.image_url
          }
          league_gateway.store_transaction(response.transaction.id, response.transaction.amount, Time.now(), credit_card, paypal)
          return {:response => response}
        else
          return {:success => false, :message => response}
        end
      end

      def subscribe(user_id, product, nonce, options = {})
        customer = self.customer(user_id)
        payment = Braintree::PaymentMethod.create(
          :customer_id => customer.id,
          :payment_method_nonce => nonce
        )
        if payment.success?
          subscription = Braintree::Subscription.create(
            :payment_method_token => payment.payment_method.token,
            :plan_id => product[:braintree_plan_id]
          )
          if subscription.success?
            league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => subscription.subscription.payment_method_token)
            league_gateway.store_token
            league_gateway.store_subscription(subscription.subscription.id, subscription.subscription.billing_period_end_date)
            subscription.subscription.transactions.each do |transaction|
              credit_card = {
                name: transaction.credit_card_details.cardholder_name,
                last_4: transaction.credit_card_details.last_4,
                expiration: transaction.credit_card_details.expiration_date,
                brand: transaction.credit_card_details.card_type
              }
              league_gateway.store_transaction(transaction.id, transaction.amount, transaction.created_at, credit_card)
            end
            return {:response => subscription}
          else
            return {:success => false, :message => subscription.errors.first.message}
          end
        else
          return {:success => false, :message => payment.errors.first.message}
        end

      end

      def unsubscribe(subscription_id, options = {})
        response = Braintree::Subscription.cancel(subscription_id)
      end

      def update_payment(user_id, product, subscription_id, nonce, options = {})
        customer = self.customer(user_id)
        payment = Braintree::PaymentMethod.create(
          :customer_id => customer.id,
          :payment_method_nonce => nonce
        )
        if payment.success?
          subscription = Braintree::Subscription.update(
            subscription_id,
            :payment_method_token => payment.payment_method.token
          )

          if subscription.success?
            league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => subscription.subscription.payment_method_token)
            league_gateway.update_token
            return {:response => subscription}
          else
            return {:response => subscription, :message => subscription.errors.first.message}
          end
        else
          return {:success => false, :message => payment.errors.first.message}
        end
      end

      def customer(user_id)
        begin
          customer = Braintree::Customer.find(user_id)
        rescue Braintree::NotFoundError => e
          user = User.find(user_id)
          result = Braintree::Customer.create(
            :email => user.email,
            :id => user_id
          )
          result.customer
        end
      end

      def parse_webhook(request)
        notification = Braintree::WebhookNotification.parse(
          request.params[:bt_signature],
          request.params[:bt_payload]
        )
        if notification.kind == "subscription_canceled"
          Jobs.enqueue(:subscription_canceled, {id: notification.subscription.id})
        elsif notification.kind == "subscription_charged_unsuccessfully"
          Jobs.enqueue(:subscription_charged_unsuccessfully, {id: notification.subscription.id})
        end
      end

    end
  end
end