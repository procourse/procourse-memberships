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

    def store_token
      tokens = PluginStore.get("discourse_league", "user_payment_tokens")
      tokens = [] if tokens.nil?
      id = SecureRandom.random_number(1000000)

      until tokens.select{|token| token[:id] == id}.empty?
        id = SecureRandom.random_number(1000000)
      end

      new_token = {
        id: id,
        user_id: @options[:user_id],
        product_id: @options[:product_id],
        token: @options[:token]
      }

      tokens.push(new_token)

      PluginStore.set("discourse_league", "user_payment_tokens", tokens)
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