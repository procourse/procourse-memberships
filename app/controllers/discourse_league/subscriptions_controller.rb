require_relative '../../../lib/discourse_league/billing/gateways'

module DiscourseLeague
  class SubscriptionsController < ApplicationController

    def all
      if current_user.id == params[:user_id].to_i
        subscriptions = PluginStore.get("discourse_league", "s:" + params[:user_id].to_s) || []

        if !subscriptions.empty?
          subscriptions = subscriptions.flatten.map{|subscription| Subscription.new(subscription)}
        end

        render_json_dump(serialize_data(subscriptions, SubscriptionSerializer))
      else
        render_json_error(params[:user_id])
      end
    end

    def show
      if current_user.id == params[:user_id].to_i
        render json: success_json
      else
        render_json_error(params[:user_id])
      end
    end

    def cancel
      subscriptions = PluginStore.get("discourse_league", "s:" + current_user.id.to_s) || []
      subscription = subscriptions.select{|subscription| subscription[:subscription_id] == params[:id].to_s}

      gateway = DiscourseLeague::Billing::Gateways.new.gateway
      response = gateway.unsubscribe(subscription[0][:subscription_id])

      if response.success?

        league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => current_user.id, :product_id => subscription[0][:product_id])
        league_gateway.unstore_subscription

        levels = PluginStore.get("discourse_league", "levels")
        level = levels.select{|level| level[:id] == subscription[0][:product_id].to_i}

        group = Group.find(level[0][:group].to_i)
        if group.users.include?(current_user)
          group.remove(current_user)
          GroupActionLogger.new(current_user, group).log_remove_user_from_group(current_user)
        end

        if group.save
          render json: PluginStore.get("discourse_league", "s:" + current_user.id.to_s) || []
        else
          return render_json_error(group)
        end
      else
        render_json_error(response.message)
      end
    end

  end
end