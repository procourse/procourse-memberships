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

    def store_subscription(subscription_id, subscription_end_date)
      subscriptions = PluginStore.get("discourse_league", "subscriptions")
      subscriptions = [] if subscriptions.nil?
      id = SecureRandom.random_number(1000000)

      until subscriptions.select{|subscription| subscription[:id] == id}.empty?
        id = SecureRandom.random_number(1000000)
      end

      new_subscription = {
        id: id,
        user_id: @options[:user_id],
        product_id: @options[:product_id],
        subscription_id: subscription_id,
        subscription_end_date: subscription_end_date
      }

      subscriptions.push(new_subscription)

      PluginStore.set("discourse_league", "subscriptions", subscriptions)
    end

    def store_transaction(transaction_id, transaction_amount, transaction_date)
      transactions = PluginStore.get("discourse_league", "transactions")
      transactions = [] if transactions.nil?
      id = SecureRandom.random_number(1000000)

      until transactions.select{|transaction| transaction[:id] == id}.empty?
        id = SecureRandom.random_number(1000000)
      end

      new_transaction = {
        id: id,
        user_id: @options[:user_id],
        product_id: @options[:product_id],
        transaction_id: transaction_id,
        transaction_amount: transaction_amount,
        transaction_date: transaction_date
      }

      transactions.push(new_transaction)

      PluginStore.set("discourse_league", "transactions", transactions)
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