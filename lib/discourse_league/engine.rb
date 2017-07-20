module DiscourseLeague
  class Engine < ::Rails::Engine
    isolate_namespace DiscourseLeague

    config.after_initialize do
  		Discourse::Application.routes.append do
  			mount ::DiscourseLeague::Engine, at: "/league"
  		end

      require_dependency 'current_user_serializer'
      class ::CurrentUserSerializer
        attributes :groups
      end 

      module ::Jobs
        class LeagueConfirmValidKey < Jobs::Scheduled
          every 1.days

          def execute(args)
            validate_url = "https://discourseleague.com/licenses/validate?id=39973&key=" + SiteSetting.league_license_key
            request = Net::HTTP.get(URI.parse(validate_url))
            result = JSON.parse(request)
            
            if result["enabled"]
              SiteSetting.league_licensed = true
            else
              SiteSetting.league_licensed = false
            end
          end

        end

        class SubscriptionCanceled < Jobs::Base
          def execute(args)
            subscription = PluginStoreRow.where(plugin_name: "discourse_league")
              .where("key LIKE 's:%'")
              .where("value LIKE '%" + args[:id] + "%'")
              .first
            user_id = subscription.key[2..-1].to_i
            byebug
          end
        end

        class SubscriptionChargedUnsuccessfully < Jobs::Base
          def execute(args)
            subscriptions = PluginStoreRow.where(plugin_name: "discourse_league")
              .where("key LIKE 's:%'")
              .where("value LIKE '%" + args[:id] + "%'")
              .first
            user_id = subscription.key[2..-1].to_i
            byebug
          end
        end

      end

    end

  end
end

require 'open-uri'
require 'net/http'

DiscourseEvent.on(:site_setting_saved) do |site_setting|
  if site_setting.name.to_s == "league_license_key" && site_setting.value_changed?

    if site_setting.value.empty?
      SiteSetting.league_licensed = false
    else
      validate_url = "https://discourseleague.com/licenses/validate?id=39973&key=" + site_setting.value
      request = Net::HTTP.get(URI.parse(validate_url))
      result = JSON.parse(request)
      
      if result["errors"]
        raise Discourse::InvalidParameters.new(
          'Sorry. That key is invalid.'
        )
      end

      if result["enabled"]
        SiteSetting.league_licensed = true
      else
        SiteSetting.league_licensed = false
      end
    end

  end
end