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

      def self.name
        SiteSetting.league_gateway.gsub(/\s+/, "").downcase
      end

      def gateway
        DiscourseLeague::Gateways.const_get((SiteSetting.league_gateway + "Gateway").to_sym).new
      end

      def store_token
        tokens = PluginStore.get("discourse_league", "tokens:" + @options[:user_id].to_s) || []
        time = Time.now

        new_token = {
          product_id: @options[:product_id],
          token: @options[:token],
          created_at: time,
          updated_at: time
        }

        tokens.push(new_token)

        PluginStore.set("discourse_league", "tokens:" + @options[:user_id].to_s, tokens)
      end

      def update_token
        tokens = PluginStore.get("discourse_league", "tokens:" + @options[:user_id].to_s) || []

        token = tokens.select{|token| token[:product_id] == @options[:product_id]}

        time = Time.now

        unless token.empty?
          token[0][:token] = @options[:token]
          token[0][:updated_at] = time
        end

        PluginStore.set("discourse_league", "tokens:" + @options[:user_id].to_s, tokens)
      end

      def store_subscription(subscription_id, subscription_end_date)
        subscriptions = PluginStore.get("discourse_league", "s:" + @options[:user_id].to_s) || []
        time = Time.now

        new_subscription = {
          product_id: @options[:product_id],
          subscription_id: subscription_id,
          subscription_end_date: subscription_end_date,
          active: true,
          created_at: time,
          updated_at: time
        }

        subscriptions.push(new_subscription)

        PluginStore.set("discourse_league", "s:" + @options[:user_id].to_s, subscriptions)
      end

      def store_transaction(transaction_id, transaction_amount, transaction_date, credit_card = {}, paypal = {})
        transactions = PluginStore.get("discourse_league", "t:" + @options[:user_id].to_s) || []
        time = Time.now

        new_transaction = {
          product_id: @options[:product_id],
          transaction_id: transaction_id,
          transaction_amount: transaction_amount,
          transaction_date: transaction_date,
          created_at: time,
          credit_card: credit_card,
          paypal: paypal
        }

        transactions.push(new_transaction)

        PluginStore.set("discourse_league", "t:" + @options[:user_id].to_s, transactions)

        username = User.find(@options[:user_id]).username

        PostCreator.create(
          DiscourseLeague.contact_user,
          target_usernames: username,
          archetype: Archetype.private_message,
          title: I18n.t('league.private_messages.receipt.title', {transactionId: transaction_id}),
          raw: I18n.t('league.private_messages.receipt.message')
        )
      end

      def unstore_subscription
        subscriptions = PluginStore.get("discourse_league", "s:" + @options[:user_id].to_s)
        subscription = subscriptions.select{|subscription| subscription[:product_id] = @options[:product_id].to_i}

        subscriptions.delete(subscription[0])
        PluginStore.set("discourse_league", "s:" + @options[:user_id].to_s, subscriptions)
      end

    end

  end
end

require_relative "../gateways/braintree"
require_relative "../gateways/paypal"
require_relative "../gateways/stripe"
