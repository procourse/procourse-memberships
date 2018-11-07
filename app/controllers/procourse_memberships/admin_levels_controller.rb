require "paypal-sdk-rest"
require 'stripe'
include PayPal::V1::BillingPlans

module ProcourseMemberships
  class AdminLevelsController < Admin::AdminController
    requires_plugin 'procourse-memberships'

    def create
      levels = PluginStore.get("procourse_memberships", "levels")

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
        name: params[:memberships_level][:name],
        enabled: params[:memberships_level][:enabled],
        group: params[:memberships_level][:group],
        trust_level: params[:memberships_level][:trust_level] || 0,
        initial_payment: params[:memberships_level][:initial_payment],
        recurring: params[:memberships_level][:recurring],
        recurring_payment: params[:memberships_level][:recurring_payment],
        recurring_payment_period: params[:memberships_level][:recurring_payment_period],
        trial: params[:memberships_level][:trial],
        trial_period: params[:memberships_level][:trial_period],
        description_raw: params[:memberships_level][:description_raw],
        description_cooked: params[:memberships_level][:description_cooked],
        welcome_message: params[:memberships_level][:welcome_message],
        braintree_plan_id: params[:memberships_level][:braintree_plan_id]
      }
      if new_level[:recurring] == true
        if SiteSetting.memberships_gateway == "PayPal" # dynamically create billing plan via PayPal API
          if SiteSetting.memberships_go_live?
              environment = PayPal::LiveEnvironment.new(SiteSetting.memberships_paypal_api_id, SiteSetting.memberships_paypal_api_secret)
          else
              environment = PayPal::SandboxEnvironment.new(SiteSetting.memberships_paypal_api_id, SiteSetting.memberships_paypal_api_secret)
          end
          client = PayPal::PayPalHttpClient.new(environment)

          request = PlanCreateRequest.new
          body = {
              :name => new_level[:name],
              :description => new_level[:name],
              :type => "infinite",
              :payment_definitions => [{
                :name => "Regular payment definition",
                :type => "REGULAR",
                :frequency => "MONTH",
                :frequency_interval => new_level[:recurring_payment_period],
                :amount =>
                {
                  :value => new_level[:recurring_payment],
                  :currency => SiteSetting.memberships_currency
                },
                :cycles => "0"
              }],
              :merchant_preferences => {
                :return_url => "#{Discourse.base_url}/memberships/l/#{new_level[:id]}",
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
                  :currency => SiteSetting.memberships_currency
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
          rescue BraintreeHttp::HttpError => e
            puts e.status_code
            puts e.result
            render_json_error(e)
            return
          end
        elsif SiteSetting.memberships_gateway == "Stripe" # dynamically create billing product/plan via Stripe API
          Stripe.api_key = SiteSetting.memberships_stripe_secret_key
          begin
            product = Stripe::Product.create({
              name: params[:memberships_level][:name],
              type: 'service',
              active: false
            })

            new_level[:stripe_product_id] = product["id"]

            plan = Stripe::Plan.create({
              product: product["id"],
              nickname: params[:memberships_level][:name] + " " + SiteSetting.memberships_currency,
              amount: params[:memberships_level][:recurring_payment].to_i * 100,
              currency: SiteSetting.memberships_currency,
              interval: 'month',
              interval_count: params[:memberships_level][:recurring_payment_period],
              trial_period_days: params[:memberships_level][:trial_period],
              active: false
            })

            new_level[:stripe_plan_id] = plan["id"]
          rescue => e
            render_json_error(e)
          end
        end
      end
      
      levels.push(new_level)
      PluginStore.set("procourse_memberships", "levels", levels)

      render json: new_level, root: false
    end

    def update
      if SiteSetting.memberships_gateway == "PayPal"
        if SiteSetting.memberships_go_live? # check if sandbox or live
          environment = PayPal::LiveEnvironment.new(SiteSetting.memberships_paypal_api_id, SiteSetting.memberships_paypal_api_secret)
        else
            environment = PayPal::SandboxEnvironment.new(SiteSetting.memberships_paypal_api_id, SiteSetting.memberships_paypal_api_secret)
        end
        client = PayPal::PayPalHttpClient.new(environment)
      elsif SiteSetting.memberships_gateway == "Stripe"
        Stripe.api_key = SiteSetting.memberships_stripe_secret_key
      end
      
      levels = PluginStore.get("procourse_memberships", "levels")
      memberships_level = levels.select{|level| level[:id] == params[:memberships_level][:id]}

      if memberships_level.empty?
        render_json_error(memberships_level)
      else
        if memberships_level[0][:recurring] == true
          if SiteSetting.memberships_gateway == 'PayPal' 
            if (memberships_level[0][:enabled] == false || memberships_level[0][:enabled] == nil) && params[:memberships_level][:enabled] == true
              if memberships_level[0][:paypal_plan_status] == "CREATED"
                  activation = PlanUpdateRequest.new(memberships_level[0][:paypal_plan_id])
                  activation.request_body([{
                    "op": "replace",
                    "path": "/",
                    "value":
                    {
                      "state": "ACTIVE"
                    }
                  }])
  
                  begin
                      activation_response = client.execute(activation)
                      puts activation_response.status_code
                      puts activation_response.result
                      memberships_level[0][:paypal_plan_status] = "ACTIVE"
                  rescue BraintreeHttp::HttpError => e
                      puts e.status_code
                      puts e.result
                      render_json_error(e)
                      return
                  end
              end
            end
          elsif SiteSetting.memberships_gateway == "Stripe"
            begin
              product = Stripe::Product.retrieve(memberships_level[0][:stripe_product_id])
              plan = Stripe::Plan.retrieve(memberships_level[0][:stripe_plan_id])
  
              product["name"] = params[:memberships_level][:name] if !params[:memberships_level][:name].nil?
              product["active"] = params[:memberships_level][:enabled]if !params[:memberships_level][:enabled].nil?
              product.save
  
              plan["active"] =  params[:memberships_level][:enabled]if !params[:memberships_level][:enabled].nil?
              plan.save
            rescue => e
              render_json_error(e)
            end
          end
        end
        
        memberships_level[0][:name] = params[:memberships_level][:name] if !params[:memberships_level][:name].nil?
        memberships_level[0][:enabled] = params[:memberships_level][:enabled] if !params[:memberships_level][:enabled].nil?
        memberships_level[0][:group] = params[:memberships_level][:group] if !params[:memberships_level][:group].nil?
        memberships_level[0][:trust_level] = params[:memberships_level][:trust_level] if !params[:memberships_level][:trust_level].nil?
        memberships_level[0][:initial_payment] = params[:memberships_level][:initial_payment] if !params[:memberships_level][:initial_payment].nil?
        memberships_level[0][:recurring] = params[:memberships_level][:recurring] if !params[:memberships_level][:recurring].nil?
        memberships_level[0][:recurring_payment] = params[:memberships_level][:recurring_payment] if !params[:memberships_level][:recurring_payment].nil?
        memberships_level[0][:recurring_payment_period] = params[:memberships_level][:recurring_payment_period] if !params[:memberships_level][:recurring_payment_period].nil?
        memberships_level[0][:trial] = params[:memberships_level][:trial] if !params[:memberships_level][:trial].nil?
        memberships_level[0][:trial_period] = params[:memberships_level][:trial_period] if !params[:memberships_level][:trial_period].nil?
        memberships_level[0][:description_raw] = params[:memberships_level][:description_raw] if !params[:memberships_level][:description_raw].nil?
        memberships_level[0][:description_cooked] = params[:memberships_level][:description_cooked] if !params[:memberships_level][:description_cooked].nil?
        memberships_level[0][:welcome_message] = params[:memberships_level][:welcome_message] if !params[:memberships_level][:welcome_message].nil?
        memberships_level[0][:braintree_plan_id] = params[:memberships_level][:braintree_plan_id] if !params[:memberships_level][:braintree_plan_id].nil?
        memberships_level[0][:stripe_product_id] = product["id"] if !product.nil?

        PluginStore.set("procourse_memberships", "levels", levels)

        render json: memberships_level, root: false
      end
    end

    def destroy
      levels = PluginStore.get("procourse_memberships", "levels")
      memberships_level = levels.select{|level| level[:id] == params[:memberships_level][:id].to_i}

      if SiteSetting.memberships_gateway == "Stripe" && memberships_level[0][:recurring] == true
        Stripe.api_key = SiteSetting.memberships_stripe_secret_key
        begin
          if !memberships_level[0][:stripe_plan_id].nil?
            plan = Stripe::Plan.retrieve(memberships_level[0][:stripe_plan_id])
            plan.delete
          end

          if !memberships_level[0][:stripe_product_id].nil?
            product = Stripe::Product.retrieve(memberships_level[0][:stripe_product_id])
            product.delete
          end
        rescue => e
          render_json_error(e)
        end
          
      end

      levels.delete(memberships_level[0])
      PluginStore.set("procourse_memberships", "levels", levels)

      render json: success_json
    end

    def show
      levels = PluginStore.get("procourse_memberships", "levels")
      render_json_dump(levels)
    end

    private

    def memberships_level_params
      params.permit(memberships_level: [:enabled, :name, :group, :trust_level, :initial_payment, :recurring, :recurring_payment, :recurring_payment_period, :trial, :trial_payment, :description_raw, :description_cooked, :welcome_message])[:memberships_level]
    end

  end
end
