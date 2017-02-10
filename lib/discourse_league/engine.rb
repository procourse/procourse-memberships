module DiscourseLeague
  class Engine < ::Rails::Engine
    isolate_namespace DiscourseLeague

    config.after_initialize do
  		Discourse::Application.routes.append do
  			mount ::DiscourseLeague::Engine, at: "/league"
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