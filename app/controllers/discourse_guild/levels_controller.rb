module DiscourseGuild
	class LevelsController < ApplicationController

	  def show
	  	@level = params[:level]
	  	render_json_dump(level: @level)
	  end

	  def all
	  	levels = Levels.all
	  	render_json_dump(levels: levels)
	  end

	end
end