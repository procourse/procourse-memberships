require_relative '../../../lib/discourse_league/gateways'

module DiscourseLeague
  class AdminGatewaysController < Admin::AdminController
    requires_plugin 'discourse-league'

    def update
      byebug
    end

    def show
      gateways = DiscourseLeague::Gateways::GATEWAYS
      render_json_dump(gateways)
    end

  end
end