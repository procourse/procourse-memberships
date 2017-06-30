module DiscourseLeague

  def self.contact_user
    user = User.find_by(username_lower: SiteSetting.league_contact_user.downcase) if SiteSetting.league_contact_user.present?
    user ||= (Discourse.site_contact_user || User.admins.real.order(:id).first)
  end

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

            user = User.find(user_id)

            gateway = DiscourseLeague::Billing::Gateways.new.gateway
            response = gateway.unsubscribe(JSON.parse(subscription.value)[0]["subscription_id"])

            if response.success?

              league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => JSON.parse(subscription.value)[0]["product_id"])
              league_gateway.unstore_subscription

              levels = PluginStore.get("discourse_league", "levels")
              level = levels.select{|level| level[:id] == JSON.parse(subscription.value)[0]["product_id"].to_i}

              group = Group.find(level[0][:group].to_i)
              if group.users.include?(user)
                group.remove(user)
                GroupActionLogger.new(user, group).log_remove_user_from_group(user)
              end

              if group.save
                PostCreator.create(
                  DiscourseLeague.contact_user,
                  target_usernames: user.username,
                  archetype: Archetype.private_message,
                  title: I18n.t('league.private_messages.subscription_canceled.title', {productName: level[0][:name]}),
                  raw: I18n.t('league.private_messages.subscription_canceled.message', {productName: level[0][:name]})
                )
              end
            end
          end
        end

        class SubscriptionChargedUnsuccessfully < Jobs::Base
          def execute(args)
            subscription = PluginStoreRow.where(plugin_name: "discourse_league")
              .where("key LIKE 's:%'")
              .where("value LIKE '%" + args[:id] + "%'")
              .first
            user_id = subscription.key[2..-1].to_i

            user = User.find(user_id)

            gateway = DiscourseLeague::Billing::Gateways.new.gateway
            response = gateway.unsubscribe(JSON.parse(subscription.value)[0]["subscription_id"])

            if response.success?

              league_gateway = DiscourseLeague::Billing::Gateways.new(:user_id => user_id, :product_id => JSON.parse(subscription.value)[0]["product_id"])
              league_gateway.unstore_subscription

              levels = PluginStore.get("discourse_league", "levels")
              level = levels.select{|level| level[:id] == JSON.parse(subscription.value)[0]["product_id"].to_i}

              group = Group.find(level[0][:group].to_i)
              if group.users.include?(user)
                group.remove(user)
                GroupActionLogger.new(user, group).log_remove_user_from_group(user)
              end

              if group.save
                PostCreator.create(
                  DiscourseLeague.contact_user,
                  target_usernames: user.username,
                  archetype: Archetype.private_message,
                  title: I18n.t('league.private_messages.subscription_charged_unsuccessfully.title', {productName: level[0][:name]}),
                  raw: I18n.t('league.private_messages.subscription_charged_unsuccessfully.message', {productName: level[0][:name]})
                )
              end
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