module DiscourseLeague
  module Billing
    class Gateways

      def initialize(options = {})
        @options = options
      end

      def self.mode
        SiteSetting.league_go_live ? :production : :test
      end

      def self.test?
        !SiteSetting.league_go_live
      end

      def gateway
        DiscourseLeague::Gateways.const_get((SiteSetting.league_gateway + "Gateway").to_sym).new
      end

      def paypal
        DiscourseLeague::Gateways::PayPalGateway.new
      end

      def store_token
        tokens = PluginStore.get("discourse_league", "user_payment_tokens")
        tokens = [] if tokens.nil?
        id = SecureRandom.random_number(1000000)
        time = Time.now

        until tokens.select{|token| token[:id] == id}.empty?
          id = SecureRandom.random_number(1000000)
        end

        new_token = {
          id: id,
          user_id: @options[:user_id],
          product_id: @options[:product_id],
          token: @options[:token],
          created_at: time
        }

        tokens.push(new_token)

        PluginStore.set("discourse_league", "user_payment_tokens", tokens)
      end

      def store_subscription(subscription_id, subscription_end_date)
        subscriptions = PluginStore.get("discourse_league", "subscriptions")
        subscriptions = [] if subscriptions.nil?
        id = SecureRandom.random_number(1000000)
        time = Time.now

        until subscriptions.select{|subscription| subscription[:id] == id}.empty?
          id = SecureRandom.random_number(1000000)
        end

        new_subscription = {
          id: id,
          user_id: @options[:user_id],
          product_id: @options[:product_id],
          subscription_id: subscription_id,
          subscription_end_date: subscription_end_date,
          active: true,
          created_at: time
        }

        subscriptions.push(new_subscription)

        PluginStore.set("discourse_league", "subscriptions", subscriptions)
      end

      def store_transaction(transaction_id, transaction_amount, transaction_date, billing_address = {}, credit_card = {})
        transactions = PluginStore.get("discourse_league", "transactions")
        transactions = [] if transactions.nil?
        id = SecureRandom.random_number(1000000)
        time = Time.now

        until transactions.select{|transaction| transaction[:id] == id}.empty?
          id = SecureRandom.random_number(1000000)
        end

        new_transaction = {
          id: id,
          user_id: @options[:user_id],
          product_id: @options[:product_id],
          transaction_id: transaction_id,
          transaction_amount: transaction_amount,
          transaction_date: transaction_date,
          created_at: time,
          billing_address: billing_address,
          credit_card: credit_card
        }

        transactions.push(new_transaction)

        PluginStore.set("discourse_league", "transactions", transactions)
      end

      def unstore_subscription(id)
        subscriptions = PluginStore.get("discourse_league", "subscriptions")
        subscription = subscriptions.select{|subscription| subscription[:id] = id.to_i}

        subscriptions.delete(subscription[0])
        PluginStore.set("discourse_league", "subscriptions", subscriptions)
      end

    end

  end
end

require_relative "../gateways/braintree"
require_relative "../gateways/paypal"