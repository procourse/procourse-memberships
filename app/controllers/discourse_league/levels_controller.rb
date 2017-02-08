module DiscourseLeague
  class LevelsController < ApplicationController

    def show

      if params[:id]
        levels = PluginStore.get("discourse_league", "levels")
        level = levels[params[:id].to_i]
      end

      if level && level[:enabled]
        render_json_dump(level)
      else
        render nothing: true, status: 404
      end

    end

  end
end