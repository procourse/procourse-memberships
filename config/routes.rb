require_dependency "guild_constraint"
require_dependency "admin_constraint"

DiscourseGuild::Engine.routes.draw do

  get '/levels' => 'levels#all', constraints: GuildConstraint.new
  get "/l/:id" => "levels#show", constraints: GuildConstraint.new
  put "/l/:id" => "levels#update", constraints: GuildConstraint.new
  delete "/l/:id" => "levels#destroy", constraints: GuildConstraint.new
  get '/pages' => 'pages#all', constraints: GuildConstraint.new
  get "/p/:id" => "pages#show", constraints: GuildConstraint.new
  get "/p/:slug/:id" => "pages#show", constraints: GuildConstraint.new
  put "/p/:id" => "pages#update", constraints: GuildConstraint.new
  delete "/p/:id" => "pages#destroy", constraints: GuildConstraint.new

  resource :admin_levels, path: '/admin/levels', constraints: AdminConstraint.new
  resource :admin_pages, path: '/admin/pages', constraints: AdminConstraint.new
end