require "paypal-sdk-rest"
include PayPal::V1::BillingPlans

module DiscourseLeague
  class AdminLevelsController < Admin::AdminController
    requires_plugin 'discourse-league'

    def create
      levels = PluginStore.get("discourse_league", "levels")

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
      if SiteSetting.league_gateway == "PayPal" && new_level[:recurring] == true
          if SiteSetting.league_go_live?
              environment = PayPal::LiveEnvironment.new(SiteSetting.league_paypal_api_id, SiteSetting.league_paypal_api_secret)
          else
              environment = PayPal::SandboxEnvironment.new(SiteSetting.league_paypal_api_id, SiteSetting.league_paypal_api_secret)
          end

          request = PlanCreateRequest.new
          body = {
              :name => new_level[:name],
              :description => new_level[:description_raw],
              :type => "infinite",
              :payment_definitions => [{
                :name => "Regular payment definition",
                :type => "REGULAR",
                :frequency => "MONTH",
                :frequency_interval => new_level[:recurring_payment_period],
                :amount =>
                {
                  :value => new_level[:recurring_payment],
                  :currency => SiteSetting.league_currency
                },
                :cycles => "0"
              }],
              :merchant_preferences => {
                :return_url => "#{Discourse.base_url}/league/l/#{new_level[:id]}",
                :cancel_url => "#{Discourse.base_url}",
                :auto_bill_amount => "YES",
                :initial_fail_amount_action => "CONTINUE",
                :max_fail_attempts => "0"
              }
          }
          if new_level[:trial] == true
              trial = {
                :name => "Trial",
                :type => "trial",
                :frequency => "day",
                :frequency_interval => "1",
                :amount =>
                {
                  :value => "0.00",
                  :currency => SiteSetting.league_currency
                },
                :cycles => new_level[:trial_period]
              }
              body[:payment_definitions] << trial
          end
          request.request_body(body)
          begin
            response = client.execute(request)
            puts response.status_code
            puts response.result
            new_level.merge!({ :paypal_plan_id => response[:result][:id], :paypal_plan_status => response[:result][:state] })
            binding.pry
          rescue BraintreeHttp::HttpError => e
            puts e.status_code
            puts e.result
            render_json_error(e)
            return
          end
      end

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