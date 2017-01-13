# name: discourse-guild
# about: Adds the ability to sell memberships to groups.
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/joebuhlig/discourse-guild

enabled_site_setting :guild_enabled

add_admin_route 'guild.title', 'guild'

register_asset "stylesheets/discourse-guild.scss"

Discourse::Application.routes.append do
	get '/admin/plugins/guild' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/guild/levels' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/guild/pages' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/guild/payment' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/guild/messages' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/guild/advanced' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/admin/plugins/guild/extras' => 'admin/plugins#index', constraints: StaffConstraint.new
	get '/g/:slug/:id' => 'levels#show'
	get '/p/:slug/:id' => 'pages#show'
end

load File.expand_path('../lib/discourse_guild/engine.rb', __FILE__)