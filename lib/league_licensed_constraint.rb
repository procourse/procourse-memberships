class LeagueLicensedConstraint
  def matches?(request)
    SiteSetting.league_licensed
  end
end