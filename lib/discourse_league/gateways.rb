module DiscourseLeague
  class Gateways
    def initialize(options = {})
      @options = options
    end

    def gateway_availability
      gateway_availability = {
        braintree: { 
          gateway_name: "Braintree", 
          am_class: "BraintreeGateway", 
          currencies: ["USD"] },
        stripe: { 
          gateway_name: "Stripe", 
          am_class: "StripeGateway", 
          currencies: ["USD"] }
      }
    end
  end
end