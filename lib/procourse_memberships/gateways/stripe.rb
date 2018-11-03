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
        begin
          charge = Stripe::Charge.create({
              amount: product[:initial_payment].to_i * 100,
              currency: SiteSetting.memberships_currency.downcase,
              description: product[:description],
              source: token,
          })
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
        rescue => e
          return {:message => e}
        end
      end

      def subscribe(user_id, product, nonce, options = {})

        begin
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

          memberships_gateway = ProcourseMemberships::Billing::Gateways.new(:user_id => user_id, :product_id => product[:id], :token => { :customer_id => customer["id"], :subscription_id => subscription["id"]})
          memberships_gateway.store_token

          memberships_gateway.store_subscription(subscription["id"], Time.at(subscription["current_period_end"]))

          subscription.success = true

          return {:response => subscription}

        rescue => e
          return {:message => e}
        end

      end

      def unsubscribe(subscription_id, options = {})
        begin
          subscription = Stripe::Subscription.retrieve(subscription_id)
          subscription.delete
          return {:response => {:success => true}}
        rescue => e
          return {:message => e}
        end
      end

      def update_payment(user_id, product, subscription_id, nonce, options = {})

        begin
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
        endpoint_secret = SiteSetting.memberships_stripe_webhook_secret

        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        event = nil

        begin
          event = Stripe::Webhook.construct_event(
            payload, sig_header, endpoint_secret
          )
        rescue JSON::ParserError => e
          status 400
          return
        rescue Stripe::SignatureVerificationError => e
          status 400
          return
        end

        PostCreator.create(
          ProcourseMemberships.contact_user,
          target_usernames: "justin",
          archetype: Archetype.private_message,
          title: "New Webhook",
          raw: "Request: " + payload.to_s
        )
        
        if payload["type"] == "customer.subscription.deleted"
          Jobs.enqueue(:subscription_canceled, {id: payload["object"]["id"]})
        elsif payload["type"] == "invoice.payment_failed"
            Jobs.enqueue(:subscription_charged_unsuccessfully, {id: payload["subscription"]})
        elsif payload["type"] == "invoice.payment_succeeded"
          object = payload["data"]["object"]
          ch = Stripe::Charge.retrieve(object["charge"])
          sub = Stripe::Subscription.retrieve(object["subscription"])

          Jobs.enqueue(:subscription_charged_successfully, {
            id: object["subscription"], 
            options: {
              paid_through: sub["current_period_end"], 
              transaction_id: object["charge"],
              transaction_amount: object["lines"]["data"][0]["amount"].to_i / 100,
              transaction_date: Time.at(object["date"]),
              credit_card: {
                name: ch["source"]["name"],
                last_4: ch["source"]["last4"],
                expiration: ch["source"]["exp_month"].to_s + "/" + ch["source"]["exp_year"].to_s,
                brand: ch["source"]["brand"],
              }
            }
          })
        end

        status 200
      end

    end
  end
end
