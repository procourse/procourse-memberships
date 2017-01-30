module DiscourseLeague
  class Gateways

    def initialize(options = {})
      @options = options
      byebug
    end

    GATEWAYS = {
      braintree: { 
        name: "Braintree", 
        class_name: "Braintree", 
        currencies: ["USD"] },
      stripe: { 
        name: "Stripe", 
        class_name: "Stripe", 
        currencies: ["USD"] }
    }

  end
end