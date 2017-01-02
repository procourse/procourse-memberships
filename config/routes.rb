require_dependency "guild_constraint"
require_dependency "admin_constraint"

DiscourseGuild::Engine.routes.draw do

	get '/levels' => 'levels#all', constraints: GuildConstraint.new
	get '/level/:id' => 'levels#show', constraints: GuildConstraint.new

	resource :admin_levels, path: '/admin/levels', constraints: AdminConstraint.new
end