module DiscourseLeague
  class LevelsController < ApplicationController

    def show
      if params[:id]
        levels = PluginStore.get("discourse_league", "levels")
        level = levels.select{|level| level[:id] == params[:id].to_i}

        if current_user
          DiscourseEvent.trigger(:league_level_page_visited, current_user.id, params[:id])
          subscriptions = PluginStore.get("discourse_league", "s:"  + current_user.id.to_s) || []
          user_subscription = subscriptions.select{|subscription| subscription[:product_id].to_i == level[0][:id].to_i} || []

          if user_subscription.empty?
            level[0][:user_subscribed] = false
          else
            level[0][:user_subscribed] = true
            level[0][:subscription_id] = user_subscription[0][:id]
          end
          
          trust_level = level[0]["trust_level"] || 0

          if current_user.trust_level >= trust_level
            level[0][:user_insufficient_tl] = false
          else
            level[0][:user_insufficient_tl] = true
          end
        else
          level[0][:user_subscribed] = false
        end
      end

      if !level.empty? && level[0][:enabled]
        render_json_dump(level)
      else
        render body: nil, status: 404
      end

    end

  end
end