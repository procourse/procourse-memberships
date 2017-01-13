# name: discourse-league
# about: Adds the ability to sell memberships to groups.
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/discourseleague/discourse-league

enabled_site_setting :league_enabled

add_admin_route 'league.title', 'league'

register_asset "stylesheets/discourse-league.scss"

Discourse::Application.routes.append do
	get '/admin/plugins/league' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/league/levels' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/league/pages' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/league/payment' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/league/messages' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/league/advanced' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/league/extras' => 'admin/plugins#index', constraints: StaffConstraint.new
end

load File.expand_path('../lib/discourse_league/engine.rb', __FILE__)