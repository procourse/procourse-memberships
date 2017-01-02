module DiscourseGuild
	class LevelsController < ApplicationController

	  def show
	  	@level = params[:level]
	  	render_json_dump(@level)
	  end

	  def all
	  	levels = Level.all
	  	render_json_dump(levels)
	  end

	end
end