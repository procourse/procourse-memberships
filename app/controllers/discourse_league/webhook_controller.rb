require_relative '../../../lib/discourse_league/gateways/braintree'

module DiscourseLeague
  class WebhookController < ApplicationController
    skip_before_filter :redirect_to_login_if_required
    layout false
    skip_before_filter :check_xhr
    skip_before_filter :verify_authenticity_token, only: [:braintree]
    def braintree
      braintree = DiscourseLeague::Gateways::BraintreeGateway.new()
      braintree.parse_webhook(request)
      render nothing: true
    end

  end
end