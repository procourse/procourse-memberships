class MembershipsConstraint
	def matches?(request)
		SiteSetting.memberships_enabled
	end
end