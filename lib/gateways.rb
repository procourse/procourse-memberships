module DiscourseLeague
  class Gateways
    def initialize

    end

    def available_gateways
      available_gateways = {[
        { braintree : {
            gateway_name : "Braintree",
            am_class : "BraintreeGateway"
            currencies : ["USD"]
          }
        },
        { strip : {
            gateway_name : "Stripe",
            am_class : "StripeGateway"
            currencies : ["USD"]
          }
        }
      ]}
    end
  end
end