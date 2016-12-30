module DiscourseGuild
	class LevelsController < ApplicationController

	  def show
	  	@level = params[:level]
	  	render_json_dump(level: @level)
	  end

	end
end