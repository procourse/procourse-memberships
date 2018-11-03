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
          return {:response => {:success => false}, :message => e}
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

        # validate webook
        begin
          event = Stripe::Webhook.construct_event(
            payload, sig_header, endpoint_secret
          )
        rescue JSON::ParserError => e
          return 400
        rescue Stripe::SignatureVerificationError => e
          return 400
        end

        if event["type"] == "customer.subscription.deleted"
          Jobs.enqueue(:subscription_canceled, {id: event["data"]["object"]["id"]})
        elsif event["type"] == "invoice.payment_failed"
            Jobs.enqueue(:subscription_charged_unsuccessfully, {id: event["data"]["object"]["subscription"]})
        elsif event["type"] == "invoice.payment_succeeded"

          if !event["data"]["object"]["charge"].blank?  # check for cases where there is a zero balance payment

            ch = Stripe::Charge.retrieve(event["data"]["object"]["charge"]) # get charge information not included on invoice
            sub = Stripe::Subscription.retrieve(event["data"]["object"]["subscription"]) # get subscription information not included on invoice

            Jobs.enqueue(:subscription_charged_successfully, {
              id: event["data"]["object"]["subscription"], 
              options: {
                paid_through: Time.at(sub["current_period_end"]), 
                transaction_id: event["data"]["object"]["charge"],
                transaction_amount: event["data"]["object"]["lines"]["data"][0]["amount"].to_i / 100,
                transaction_date: Time.at(event["data"]["object"]["date"]),
                credit_card: {
                  name: ch["source"]["name"],
                  last_4: ch["source"]["last4"],
                  expiration: ch["source"]["exp_month"].to_s + "/" + ch["source"]["exp_year"].to_s,
                  brand: ch["source"]["brand"],
                }
              }
            })
          end
        end

        return 200
      end

    end
  end
end
