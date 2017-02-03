require 'active_merchant'
require_relative '../../../lib/discourse_league/gateways'

module DiscourseLeague
  class CheckoutController < ApplicationController

    def submit_billing_payment
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
        errors = ""
        errors += I18n.t('league.errors.first_name') + " " + valid_card[:first_name][0] + "<br>" if !valid_card[:first_name].nil?
        errors += I18n.t('league.errors.last_name') + " " + valid_card[:last_name][0] + "<br>" if !valid_card[:last_name].nil?
        errors += I18n.t('league.errors.card_number') + " " + valid_card[:number][0] + "<br>" if !valid_card[:number].nil?
        errors += I18n.t('league.errors.expiration_month') + " " + valid_card[:month][0] + "<br>" if !valid_card[:month].nil?
        errors += I18n.t('league.errors.expiration_year') + " " + valid_card[:year][0] + "<br>" if !valid_card[:year].nil?
        errors += I18n.t('league.errors.cvv') + " " + valid_card[:verification_value][0] + "<br>" if !valid_card[:verification_value].nil?
        return render_json_error(errors)
      else
        render json: success_json
      end
    end

    def submit_verify
      gateway = DiscourseLeague::Gateways.new.gateway
      byebug
    end

  end
end