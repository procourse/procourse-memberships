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
          response
        else
          return {:success => false, :message => response}
        end
      end

      def subscribe(user_id, product, nonce, options = {})
        response = store(credit_card_or_vault_id, :billing_address => options[:billing_address])

        if response.success?
          league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => response.params["credit_card_token"])
          league_gateway.store_token
          subscription = @braintree_gateway.subscription.create(:payment_method_token => response.params["credit_card_token"], :plan_id => product[:braintree_plan_id])

          if subscription.success?
            league_gateway.store_subscription(subscription.subscription.id, subscription.subscription.billing_period_end_date)
            subscription.subscription.transactions.each do |transaction|
              credit_card = {
                name: transaction.credit_card_details.cardholder_name,
                last_4: transaction.credit_card_details.last_4,
                expiration: transaction.credit_card_details.expiration_date,
                brand: transaction.credit_card_details.card_type
              }
              league_gateway.store_transaction(transaction.id, transaction.amount, transaction.created_at, options[:billing_address], credit_card)
            end
            subscription
          else
            return {:success => false, :message => message_from_result(subscription)}
          end
        else
          return {:success => false, :message => message_from_result(response)}
        end

      end

      def unsubscribe(subscription_id, options = {})
        response = @braintree_gateway.subscription.cancel(subscription_id)
        if response.success?
          response
        else
          return {:success => false, :message => message_from_result(response)}
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

    end
  end
end