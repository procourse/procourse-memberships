require 'active_merchant'
require_relative '../../../lib/discourse_league/gateways'

module DiscourseLeague
  class CheckoutController < ApplicationController

    def submit_billing_payment
      gateways = DiscourseLeague::Gateways::GATEWAYS
      active_gateway = "braintree"
      gw = gateways[active_gateway.to_sym]
      
      byebug
    end

    def submit_verify
      byebug
    end

  end
end