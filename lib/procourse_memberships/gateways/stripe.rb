require_relative '../billing/gateways'
require 'stripe'

module ProcourseMemberships
  class Gateways
    class StripeGateway

      def initialize(options = {})
         Stripe.api_key = SiteSetting.memberships_stripe_secret_key
      end

      def purchase(user_id, product, nonce, options = {})
        token = nonce[:stripeToken]

        charge = Stripe::Charge.create({
            amount: product[:initial_payment],
            currency: SiteSetting.memberships_currency.downcase,
            description: product[:description],
            source: token,
        })
        if charge.success?
            league_gateway = ProcourseMemberships::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => charge.source.fingerprint)
            league_gateway.store_token

            credit_card = {
                name: charge.source.name
                last_4: charge.source.last4
                expiration: charge.source.exp_month + "/" + charge.source.exp_year
                brand: charge.source.brand
                image: 
            }
            league_gateway.store_transaction(charge.transaction.id, charge.transaction.amount, Time.now(), credit_card, nil)

            return {:response => charge}
        else
            return {:success => false, :message => charge}
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
