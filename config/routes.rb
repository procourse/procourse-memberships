require_dependency "league_constraint"
require_dependency "admin_constraint"

DiscourseLeague::Engine.routes.draw do

  get "/l/:id" => "levels#show", constraints: LeagueConstraint.new
  post '/checkout/submit-payment' => "checkout#submit_payment", constraints: LeagueConstraint.new
  get '/checkout/braintree-token' => "checkout#braintree_token", constraints: LeagueConstraint.new
  post '/checkout/verify' => "checkout#submit_verify", constraints: LeagueConstraint.new
  get '/subscriptions/:user_id' => "subscriptions#all", constraints: LeagueConstraint.new
  get '/subscriptions/:user_id/:id' => "subscriptions#show", constraints: LeagueConstraint.new
  put '/subscriptions/:id' => "subscriptions#update", constraints: LeagueConstraint.new
  delete '/subscriptions/:id' => "subscriptions#cancel", constraints: LeagueConstraint.new
  get '/transactions/:user_id' => "transactions#all", constraints: LeagueConstraint.new
  get '/transactions/:user_id/:id' => "transactions#show", constraints: LeagueConstraint.new

  resource :admin_levels, path: '/admin/levels', constraints: AdminConstraint.new
  resource :admin_gateways, path: '/admin/gateways', constraints: AdminConstraint.new

  post '/webhook/braintree' => "webhook#braintree", constraints: LeagueConstraint.new
  post '/webhook/paypal' => "webhook#paypal", constraints: LeagueConstraint.new
end
