module DiscourseLeague
  class Gateways

    def initialize(options = {})
      @options = options
    end

    def gateway
      unless SiteSetting.league_go_live
        ActiveMerchant::Billing::Base.mode = :test
      end
      gateway = GATEWAYS[SiteSetting.league_gateway.to_sym]
      am_gateway = DiscourseLeague::Gateways.const_get(gateway[:class_name]).new.active_merchant
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

require_relative "gateways/braintree"