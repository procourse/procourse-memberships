require_relative '../../../lib/procourse_memberships/billing/gateways'

module ProcourseMemberships
  class SubscriptionsController < ApplicationController

    def all
      if current_user.id == params[:user_id].to_i
        subscriptions = PluginStore.get("procourse_memberships", "s:" + params[:user_id].to_s) || []

        if !subscriptions.empty?
          subscriptions = subscriptions.flatten.map{|subscription| Subscription.new(subscription)}
        end

        render_json_dump(serialize_data(subscriptions, SubscriptionSerializer))
      else
        render_json_error(params[:user_id])
      end
    end

    def show
      if current_user.id == params[:user_id].to_i
        render json: success_json
      else
        render_json_error(params[:user_id])
      end
    end

    def cancel
      subscriptions = PluginStore.get("procourse_memberships", "s:" + current_user.id.to_s) || []
      subscription = subscriptions.select{|subscription| subscription[:subscription_id] == params[:id].to_s}

      gateway = ProcourseMemberships::Billing::Gateways.new.gateway
      response = gateway.unsubscribe(subscription[0][:subscription_id])

     
      if ProcourseMemberships::Billing::Gateways.name == "paypal" || ProcourseMemberships::Billing::Gateways.name == "stripe"
        success = response[:response][:success] == true
      else
        success = response.success?
      end
      
      if success

        memberships_gateway = ProcourseMemberships::Billing::Gateways.new(:user_id => current_user.id, :product_id => subscription[0][:product_id])
        memberships_gateway.unstore_subscription

        levels = PluginStore.get("procourse_memberships", "levels")
        level = levels.select{|level| level[:id] == subscription[0][:product_id].to_i}

        group = Group.find(level[0][:group].to_i)
        if group.users.include?(current_user)
          group.remove(current_user)
        end

        if group.save
          PostCreator.create(
            ProcourseMemberships.contact_user,
            target_usernames: current_user.username,
            archetype: Archetype.private_message,
            title: I18n.t('memberships.private_messages.subscription_canceled.title', {productName: level[0][:name]}),
            raw: I18n.t('memberships.private_messages.subscription_canceled.message', {productName: level[0][:name]})
          )
          render json: PluginStore.get("procourse_memberships", "s:" + current_user.id.to_s) || []
        else
          return render_json_error(group)
        end
      else
        render_json_error(response.message)
      end
    end

  end
end
