require 'active_merchant'
require_relative '../../../lib/discourse_league/gateways'

module DiscourseLeague
  class CheckoutController < ApplicationController

    before_filter :validate_card, only: [:submit_billing_payment, :submit_verify]

    def submit_billing_payment
      if !@errors.nil?
        return render_json_error(@errors)
      else
        render json: success_json
      end
    end

    def submit_verify
      if !@errors.nil?
        return render_json_error(@errors)
      else
        gateway = DiscourseLeague::Gateways.new.gateway

        billing_address = {
          :address1 => params[:address_1],
          :address2 => params[:address_2],
          :city => params[:city],
          :state => params[:billing_state],
          :zip => params[:postal_code],
          :country_name => params[:country],
          :phone => params[:phone]
        }

        products = PluginStore.get("discourse_league", "levels")
        product = products.select{|level| level[:id] == params[:product_id]}

        response = gateway.subscribe(current_user.id, product[0], @credit_card, :billing_address => billing_address)

        if response.success?
          render json: success_json
        else
          return render_json_error(response.message)
        end
      end
    end

    private

      def validate_card
        @credit_card = ActiveMerchant::Billing::CreditCard.new(
          :number => params[:card_number],
          :month => params[:expiration_month],
          :year => params[:expiration_year],
          :first_name => params[:first_name],
          :last_name => params[:last_name],
          :verification_value => params[:cvv],
          :brand => 'visa'
        )
        valid_card = @credit_card.validate
        if !valid_card.empty?
          @errors = ""
          @errors += I18n.t('league.errors.first_name') + " " + valid_card[:first_name][0] + "<br>" if !valid_card[:first_name].nil?
          @errors += I18n.t('league.errors.last_name') + " " + valid_card[:last_name][0] + "<br>" if !valid_card[:last_name].nil?
          @errors += I18n.t('league.errors.card_number') + " " + valid_card[:number][0] + "<br>" if !valid_card[:number].nil?
          @errors += I18n.t('league.errors.expiration_month') + " " + valid_card[:month][0] + "<br>" if !valid_card[:month].nil?
          @errors += I18n.t('league.errors.expiration_year') + " " + valid_card[:year][0] + "<br>" if !valid_card[:year].nil?
          @errors += I18n.t('league.errors.cvv') + " " + valid_card[:verification_value][0] + "<br>" if !valid_card[:verification_value].nil?
        end
      end

  end
end