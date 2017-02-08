module DiscourseLeague
  class AdminLevelsController < Admin::AdminController
    requires_plugin 'discourse-league'

    def create
      levels = PluginStore.get("discourse_league", "levels")
      id = SecureRandom.random_number(10000)

      if levels.nil?
        levels = []
      else
        until levels[id].nil?
          id = SecureRandom.random_number(10000)
        end
      end

      new_level = {
        id: id,
        name: params[:league_level][:name],
        enabled: params[:league_level][:enabled],
        group: params[:league_level][:group],
        initial_payment: params[:league_level][:initial_payment],
        recurring: params[:league_level][:recurring],
        recurring_payment: params[:league_level][:recurring_payment],
        recurring_period_amount: params[:league_level][:recurring_period_amount],
        recurring_period_unit: params[:league_level][:recurring_period_unit],
        trial: params[:league_level][:trial],
        trial_period: params[:league_level][:trial_period]
      }

      levels[id] = new_level
      PluginStore.set("discourse_league", "levels", levels)

      render json: new_level, root: false
    end

    def update
      levels = PluginStore.get("discourse_league", "levels")
      league_level = levels[params[:league_level][:id]]

      league_level[:name] = params[:league_level][:name] if !params[:league_level][:name].nil?
      league_level[:enabled] = params[:league_level][:enabled] if !params[:league_level][:enabled].nil?
      league_level[:group] = params[:league_level][:group] if !params[:league_level][:group].nil?
      league_level[:initial_payment] = params[:league_level][:initial_payment] if !params[:league_level][:initial_payment].nil?
      league_level[:recurring] = params[:league_level][:recurring] if !params[:league_level][:recurring].nil?
      league_level[:recurring_payment] = params[:league_level][:recurring_payment] if !params[:league_level][:recurring_payment].nil?
      league_level[:recurring_payment_amount] = params[:league_level][:recurring_payment_amount] if !params[:league_level][:recurring_payment_amount].nil?
      league_level[:recurring_payment_unit] = params[:league_level][:recurring_payment_unit] if !params[:league_level][:recurring_payment_unit].nil?
      league_level[:trial] = params[:league_level][:trial] if !params[:league_level][:trial].nil?
      league_level[:trial_period] = params[:league_level][:trial_period] if !params[:league_level][:trial_period].nil?
      league_level[:save]

      levels[params[:league_level][:id]] = league_level

      PluginStore.set("discourse_league", "levels", levels)

      render json: league_level, root: false
    end

    def destroy
      levels = PluginStore.get("discourse_league", "levels")

      levels[params[:league_level][:id]] = nil
      PluginStore.set("discourse_league", "levels", levels)

      render json: success_json
    end

    def show
      levels = PluginStore.get("discourse_league", "levels")
      render_json_dump(levels.compact)
    end

    private

    def league_level_params
      params.permit(league_level: [:enabled, :name, :group, :initial_payment, :recurring, :recurring_payment, :trial, :trial_payment])[:league_level]
    end
  end
end