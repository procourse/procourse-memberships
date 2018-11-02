require_relative '../billing/gateways'
require 'stripe'

module ProcourseMemberships
  class Gateways
    class StripeGateway

      def initialize(options = {})
         Stripe.api_key = SiteSetting.memberships_stripe_secret_key
      end

      def purchase(user_id, product, nonce, options = {})
        token = nonce[:id]

        charge = Stripe::Charge.create({
            amount: product[:initial_payment].to_i * 100,
            currency: SiteSetting.memberships_currency.downcase,
            description: product[:description],
            source: token,
        })
        if charge.status == "succeeded"
            memberships_gateway = ProcourseMemberships::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => charge.source.fingerprint)
            memberships_gateway.store_token
            
            credit_card = {
                name: charge.source.name,
                last_4: charge.source.last4,
                expiration: charge.source.exp_month.to_s + "/" + charge.source.exp_year.to_s,
                brand: charge.source.brand,
                image: nil
            }
            memberships_gateway.store_transaction(charge.id, charge.amount / 100, Time.now(), credit_card, nil)
            charge.success = true
            return {:response => charge}
        else
            charge.success = false
            return {:message => charge}
        end
      end

      def subscribe(user_id, product, nonce, options = {})
        customer = Stripe::Customer.create(
          :description => user_id,
          :source => nonce[:id]
        )
        
        subscription = Stripe::Subscription.create({
          customer: customer["id"],
          trial_from_plan: product[:trial],
          items: [{
            plan: product[:stripe_plan_id]
          }]
        })

        if subscription.status == "active"
          memberships_gateway = ProcourseMemberships::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => { :customer_id => customer["id"], :subscription_id => subscription["id"]})
          memberships_gateway.store_token

          memberships_gateway.store_subscription(subscription["id"], Time.at(subscription["current_period_end"]))

          subscription.success = true

          return {:response => subscription}

        else
          subscription.success = false
          return {:message => subscription}
        end

      end

      def unsubscribe(subscription_id, options = {})
        sub = Stripe::Subscription.retrieve(subscription_id)
        sub.delete

        if sub["status"] == "canceled"
          sub.success = true
          return {:response => sub}
        else
          sub.success = false
          return {:message => sub}
        end
      end

      def update_payment(user_id, product, subscription_id, nonce, options = {})

        begin
          binding.pry
          sub = Stripe::Subscription.retrieve(subscription_id)
          customer = Stripe::Customer.retrieve(sub["customer"])

          customer.source = nonce[:id]

          customer.save
          customer.success = true
          return {:response => customer}
        rescue => e 
          return {:success => false, :message => e}
        end

      end

      def customer(user_id)

      end

      def parse_webhook(request)

      end

    end
  end
end
