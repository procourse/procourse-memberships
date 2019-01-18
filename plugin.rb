# name: procourse-memberships
# about: Adds the ability to sell memberships to groups.
# version: 1.0
# author: Joe Buhlig joebuhlig.com
# contributors: Justin DiRose justindirose.com
# url: https://www.github.com/discourseleague/discourse-league

enabled_site_setting :memberships_enabled

register_svg_icon "credit-card" if respond_to?(:register_svg_icon)

add_admin_route 'memberships.title', 'memberships'

register_asset "stylesheets/procourse-memberships.scss"

gem 'braintree', '2.50.0'
gem 'braintreehttp', '0.5.0'
gem 'paypal-sdk-rest', '2.0.0.rc2'
gem 'stripe', '3.28.0'

load File.expand_path('../lib/procourse_memberships/engine.rb', __FILE__)

after_initialize do

	Discourse::Application.routes.append do
		get '/admin/plugins/memberships' => 'admin/plugins#index', constraints: StaffConstraint.new
		get '/admin/plugins/memberships/logs' => 'admin/plugins#index', constraints: StaffConstraint.new
		get '/admin/plugins/memberships/levels' => 'admin/plugins#index', constraints: StaffConstraint.new
		get '/admin/plugins/memberships/gateways' => 'admin/plugins#index', constraints: StaffConstraint.new
		get '/admin/plugins/memberships/messages' => 'admin/plugins#index', constraints: StaffConstraint.new
		get '/admin/plugins/memberships/advanced' => 'admin/plugins#index', constraints: StaffConstraint.new
		get '/admin/plugins/memberships/extras' => 'admin/plugins#index', constraints: StaffConstraint.new
	  get "u/:username/billing" => "users#show", constraints: {username: USERNAME_ROUTE_FORMAT}
	end

	load File.expand_path('../app/jobs/onceoff/migrate_memberships_plugin.rb', __FILE__)

end
