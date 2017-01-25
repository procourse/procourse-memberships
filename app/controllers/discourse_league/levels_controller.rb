module DiscourseLeague
  class LevelsController < ApplicationController

    def show
      if params[:id]
        @level = Level.find(params[:id])
      end

      if @level.valid? && @level.enabled?
        render_json_dump(@level)
      else
        render nothing: true, status: 404
      end

    end

    def all
      levels = Level.all
      render_json_dump(levels)
    end

  end
end