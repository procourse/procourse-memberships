DiscourseGuild::Engine.routes.draw do

  class GuildEnabledConstraint
    def matches?(request)
      byebug
      SiteSetting.guild_enabled
    end
  end

  get 'l/:level' => "levels#show"

end