require_relative '../../../lib/discourse_league/gateways'

module DiscourseLeague
  class SubscriptionsController < ApplicationController

    def all
      if current_user.id == params[:user_id].to_i
        subscriptions = PluginStore.get("discourse_league", "subscriptions")

        if !subscriptions.nil?
          subscriptions = subscriptions.select{|subscription| subscription[:user_id] == params[:user_id].to_i}
          subscriptions = subscriptions.flatten.map{|subscription| Subscription.new(subscription)} if !subscriptions.empty?
        else
          subscriptions = []
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
      subscriptions = PluginStore.get("discourse_league", "subscriptions") || []
      subscription = subscriptions.select{|subscription| subscription[:id] == params[:id].to_i}

      if current_user.id == subscription[0][:user_id].to_i
        gateway = DiscourseLeague::Gateways.new.gateway
        response = gateway.unsubscribe(subscription[0][:subscription_id])

        if response.success?
          products = PluginStore.get("discourse_league", "levels")
          product = products.select{|level| level[:id] == subscription[0][:product_id].to_i}

          league_gateway = DiscourseLeague::Gateways.new
          league_gateway.unstore_subscription(subscription[0][:id])

          group = Group.find(product[0][:group].to_i)
          if group.users.include?(current_user)
            group.remove(current_user)
            GroupActionLogger.new(current_user, group).log_remove_user_from_group(current_user)
          end

          if group.save
            render json: success_json
          else
            return render_json_error(group)
          end
        else
          render_json_error(response.message)
        end
      else
        render_json_error(params[:id])
      end
    end

  end
end