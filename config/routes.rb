require_dependency "guild_constraint"

DiscourseGuild::Engine.routes.draw do

  get '/levels' => 'levels#all', constraints: GuildConstraint.new
  get '/level/:id' => 'levels#show', constraints: GuildConstraint.new

end