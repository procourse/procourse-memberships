require_dependency "league_constraint"
require_dependency "admin_constraint"

DiscourseLeague::Engine.routes.draw do

  get '/levels' => 'levels#all', constraints: LeagueConstraint.new
  get "/l/:id" => "levels#show", constraints: LeagueConstraint.new
  put "/l/:id" => "levels#update", constraints: LeagueConstraint.new
  delete "/l/:id" => "levels#destroy", constraints: LeagueConstraint.new
  get '/pages' => 'pages#all', constraints: LeagueConstraint.new
  get "/p/:id" => "pages#show", constraints: LeagueConstraint.new
  get "/p/:slug/:id" => "pages#show", constraints: LeagueConstraint.new
  put "/p/:id" => "pages#update", constraints: LeagueConstraint.new
  delete "/p/:id" => "pages#destroy", constraints: LeagueConstraint.new
  post '/checkout/billing-payment' => "checkout#submit_billing_payment", constraints: LeagueConstraint.new
  post '/checkout/verify' => "checkout#submit_verify", constraints: LeagueConstraint.new

  resource :admin_levels, path: '/admin/levels', constraints: AdminConstraint.new
  resource :admin_pages, path: '/admin/pages', constraints: AdminConstraint.new
end