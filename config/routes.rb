require_dependency "memberships_constraint"
require_dependency "admin_constraint"

ProcourseMemberships::Engine.routes.draw do

  get "/l/:id" => "levels#show", constraints: MembershipsConstraint.new
  post '/checkout/submit-payment' => "checkout#submit_payment", constraints: MembershipsConstraint.new
  get '/checkout/braintree-token' => "checkout#braintree_token", constraints: MembershipsConstraint.new
  post '/checkout/verify' => "checkout#submit_verify", constraints: MembershipsConstraint.new
  get '/subscriptions/:user_id' => "subscriptions#all", constraints: MembershipsConstraint.new
  get '/subscriptions/:user_id/:id' => "subscriptions#show", constraints: MembershipsConstraint.new
  put '/subscriptions/:id' => "subscriptions#update", constraints: MembershipsConstraint.new
  delete '/subscriptions/:id' => "subscriptions#cancel", constraints: MembershipsConstraint.new
  get '/transactions/:user_id' => "transactions#all", constraints: MembershipsConstraint.new
  get '/transactions/:user_id/:id' => "transactions#show", constraints: MembershipsConstraint.new

  resource :admin_levels, path: '/admin/levels', constraints: AdminConstraint.new
  resource :admin_gateways, path: '/admin/gateways', constraints: AdminConstraint.new

  post '/webhook/braintree' => "webhook#braintree", constraints: MembershipsConstraint.new
  post '/webhook/paypal' => "webhook#paypal", constraints: MembershipsConstraint.new
end
