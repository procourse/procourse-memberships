module ::DiscourseGuild
	class Page < ActiveRecord::Base
	end
end

# == Schema Information
#
# Table name: discourse_guild_pages
#
#  id                :integer          not null, primary key
#  active            :boolean          default(FALSE)
#  title       	     :string           not null
#  slug              :text             not null
#  raw               :text             not null
#  cooked            :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null