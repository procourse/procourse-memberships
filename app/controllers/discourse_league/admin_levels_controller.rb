module DiscourseLeague
  class AdminLevelsController < Admin::AdminController
    requires_plugin 'discourse-league'

    before_filter :fetch_league_level, only: [:update, :destroy]

    def index
      render_serialized([Level.base] + Level.current_version.order('id ASC').all.to_a, LevelSerializer)
    end

    def create
      league_level = Level.create(league_level_params)
      if league_level.valid?
        render json: league_level, root: false
      else
        render_json_error(league_level)
      end
    end

    def update
      @league_level.name = params[:league_level][:name] if !params[:league_level][:name].nil?
      @league_level.enabled = params[:league_level][:enabled] if !params[:league_level][:enabled].nil?
      @league_level.group = params[:league_level][:group] if !params[:league_level][:group].nil?
      @league_level.initial_payment = params[:league_level][:initial_payment] if !params[:league_level][:initial_payment].nil?
      @league_level.recurring = params[:league_level][:recurring] if !params[:league_level][:recurring].nil?
      @league_level.recurring_payment = params[:league_level][:recurring_payment] if !params[:league_level][:recurring_payment].nil?
      @league_level.trial = params[:league_level][:trial] if !params[:league_level][:trial].nil?
      @league_level.trial_period = params[:league_level][:trial_period] if !params[:league_level][:trial_period].nil?
      @league_level.save

      if @league_level.valid?
        render json: @league_level, root: false
      else
        render_json_error(@league_level)
      end
    end

    def destroy
      @league_level.destroy
      render json: success_json
    end

    def show
      @level = params[:level]
      render_json_dump(level: @level)
    end

    def all
      levels = Level.all
      render_json_dump(levels: levels)
    end


    private

    def fetch_league_level
      @league_level = Level.find(params[:league_level][:id])
    end

    def league_level_params
      params.permit(league_level: [:enabled, :name, :group, :initial_payment, :recurring, :recurring_payment, :trial, :trial_payment])[:league_level]
    end
  end
end