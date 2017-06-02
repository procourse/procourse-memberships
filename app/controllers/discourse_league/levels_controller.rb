module DiscourseLeague
  class LevelsController < ApplicationController

    def show
      DiscourseEvent.trigger(:league_level_page_visited, current_user.id, params[:id])
      if params[:id]
        levels = PluginStore.get("discourse_league", "levels")
        level = levels.select{|level| level[:id] == params[:id].to_i}

        subscriptions = PluginStore.get("discourse_league", "subscriptions") || []
        user_subscription = subscriptions.select{|subscription| subscription[:product_id].to_i == level[0][:id].to_i && subscription[:user_id] == current_user.id} || []

        if user_subscription.empty?
          level[0][:user_subscribed] = false
        else
          level[0][:user_subscribed] = true
          level[0][:subscription_id] = user_subscription[0][:id]
        end
      end

      if !level.empty? && level[0][:enabled]
        render_json_dump(level)
      else
        render nothing: true, status: 404
      end

    end

  end
end