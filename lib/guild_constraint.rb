class GuildConstraint
	def matches?(request)
		SiteSetting.guild_enabled
	end
end