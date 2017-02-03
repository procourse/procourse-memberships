require 'active_merchant'
require_relative '../../../lib/discourse_league/gateways'

module DiscourseLeague
  class CheckoutController < ApplicationController

    def submit_billing_payment
      gateway = DiscourseLeague::Gateways.new.gateway
      byebug
    end

    def submit_verify
      byebug
    end

  end
end