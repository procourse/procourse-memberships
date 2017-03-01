module DiscourseLeague
  class LevelsController < ApplicationController

    def show
      DiscourseEvent.trigger(:league_level_page_visited, current_user.id, params[:id])
      if params[:id]
        levels = PluginStore.get("discourse_league", "levels")
        level = levels.select{|level| level[:id] == params[:id].to_i}
      end

      if !level.empty? && level[0][:enabled]
        render_json_dump(level)
      else
        render nothing: true, status: 404
      end

    end

  end
end