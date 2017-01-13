class LeagueConstraint
	def matches?(request)
		SiteSetting.league_enabled
	end
end