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

    end

  end
end