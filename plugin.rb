# name: discourse-guild
# about: Adds the ability to sell memberships to groups.
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/joebuhlig/discourse-guild

enabled_site_setting :guild_enabled

add_admin_route 'guild.title', 'guild'

Discourse::Application.routes.append do
  get '/admin/plugins/guild' => 'admin/plugins#index', constraints: StaffConstraint.new
end