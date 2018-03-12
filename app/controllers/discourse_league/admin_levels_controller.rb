module DiscourseLeague
  class AdminLevelsController < Admin::AdminController
    requires_plugin 'discourse-league'

    def create
      levels = PluginStore.get("discourse_league", "levels")

      if Rails.env == "production"
        if !SiteSetting.league_licensed_bronze && !SiteSetting.league_licensed_silver && !SiteSetting.league_licensed_gold
          return render_json_dump({"errors": I18n.t('league.admin.not_licensed_message')})
        elsif SiteSetting.league_licensed_bronze && levels.count >= 1
          return render_json_dump({"errors": I18n.t('league.admin.not_licensed_message')})
        elsif SiteSetting.league_licensed_silver && levels.count >= 3
          return render_json_dump({"errors": I18n.t('league.admin.not_licensed_message')})
        end            
      end

      id = SecureRandom.random_number(10000)

      if levels.nil?
        levels = []
      else
        until levels.select{|level| level[:id] == id}.empty?
          id = SecureRandom.random_number(10000)
        end
      end

      new_level = {
        id: id,
        name: params[:league_level][:name],
        enabled: params[:league_level][:enabled],
        group: params[:league_level][:group],
        trust_level: params[:league_level][:trust_level] || 0,
        initial_payment: params[:league_level][:initial_payment],
        recurring: params[:league_level][:recurring],
        recurring_payment: params[:league_level][:recurring_payment],
        recurring_payment_period: params[:league_level][:recurring_payment_period],
        trial: params[:league_level][:trial],
        trial_period: params[:league_level][:trial_period],
        description_raw: params[:league_level][:description_raw],
        description_cooked: params[:league_level][:description_cooked],
        welcome_message: params[:league_level][:welcome_message],
        braintree_plan_id: params[:league_level][:braintree_plan_id]
      }

      levels.push(new_level)
      PluginStore.set("discourse_league", "levels", levels)

      render json: new_level, root: false
    end

    def update
      levels = PluginStore.get("discourse_league", "levels")
      league_level = levels.select{|level| level[:id] == params[:league_level][:id]}

      if league_level.empty?
        render_json_error(league_level)
      else
        league_level[0][:name] = params[:league_level][:name] if !params[:league_level][:name].nil?
        league_level[0][:enabled] = params[:league_level][:enabled] if !params[:league_level][:enabled].nil?
        league_level[0][:group] = params[:league_level][:group] if !params[:league_level][:group].nil?
        league_level[0][:trust_level] = params[:league_level][:trust_level] if !params[:league_level][:trust_level].nil?
        league_level[0][:initial_payment] = params[:league_level][:initial_payment] if !params[:league_level][:initial_payment].nil?
        league_level[0][:recurring] = params[:league_level][:recurring] if !params[:league_level][:recurring].nil?
        league_level[0][:recurring_payment] = params[:league_level][:recurring_payment] if !params[:league_level][:recurring_payment].nil?
        league_level[0][:recurring_payment_period] = params[:league_level][:recurring_payment_period] if !params[:league_level][:recurring_payment_period].nil?
        league_level[0][:trial] = params[:league_level][:trial] if !params[:league_level][:trial].nil?
        league_level[0][:trial_period] = params[:league_level][:trial_period] if !params[:league_level][:trial_period].nil?
        league_level[0][:description_raw] = params[:league_level][:description_raw] if !params[:league_level][:description_raw].nil?
        league_level[0][:description_cooked] = params[:league_level][:description_cooked] if !params[:league_level][:description_cooked].nil?
        league_level[0][:welcome_message] = params[:league_level][:welcome_message] if !params[:league_level][:welcome_message].nil?
        league_level[0][:braintree_plan_id] = params[:league_level][:braintree_plan_id] if !params[:league_level][:braintree_plan_id].nil?

        PluginStore.set("discourse_league", "levels", levels)

        render json: league_level, root: false
      end
    end

    def destroy
      levels = PluginStore.get("discourse_league", "levels")
      league_level = levels.select{|level| level[:id] == params[:league_level][:id].to_i}

      levels.delete(league_level[0])
      PluginStore.set("discourse_league", "levels", levels)

      render json: success_json
    end

    def show
      levels = PluginStore.get("discourse_league", "levels")
      render_json_dump(levels)
    end

    private

    def league_level_params
      params.permit(league_level: [:enabled, :name, :group, :trust_level, :initial_payment, :recurring, :recurring_payment, :recurring_payment_period, :trial, :trial_payment, :description_raw, :description_cooked, :welcome_message])[:league_level]
    end
  end
end