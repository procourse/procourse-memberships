module DiscourseGuild
  class AdminLevelsController < Admin::AdminController
    requires_plugin 'discourse-guild'

    before_filter :fetch_guild_level, only: [:update, :destroy]

    def index
      render_serialized([Level.base] + Level.current_version.order('id ASC').all.to_a, LevelSerializer)
    end

    def create
      guild_level = Level.create(guild_level_params)
      if guild_level.valid?
        render json: guild_level, root: false
      else
        render_json_error(guild_level)
      end
    end

    def update
      @guild_level.name = params[:guild_level][:name] if !params[:guild_level][:name].nil?
      @guild_level.enabled = params[:guild_level][:enabled] if !params[:guild_level][:enabled].nil?
      @guild_level.group = params[:guild_level][:group] if !params[:guild_level][:group].nil?
      @guild_level.initial_payment = params[:guild_level][:initial_payment] if !params[:guild_level][:initial_payment].nil?
      @guild_level.recurring = params[:guild_level][:recurring] if !params[:guild_level][:recurring].nil?
      @guild_level.recurring_payment = params[:guild_level][:recurring_payment] if !params[:guild_level][:recurring_payment].nil?
      @guild_level.trial = params[:guild_level][:trial] if !params[:guild_level][:trial].nil?
      @guild_level.trial_period = params[:guild_level][:trial_period] if !params[:guild_level][:trial_period].nil?
      @guild_level.save

      if @guild_level.valid?
        render json: @guild_level, root: false
      else
        render_json_error(@guild_level)
      end
    end

    def destroy
      @guild_level.destroy
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

    def fetch_guild_level
      @guild_level = Level.find(params[:guild_level][:id])
    end

    def guild_level_params
      params.permit(guild_level: [:enabled, :name, :group, :initial_payment, :recurring, :recurring_payment, :trial, :trial_payment])[:guild_level]
    end
  end
end