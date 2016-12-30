module ::DiscourseGuild
	class Levels < ActiveRecord::Base
	end
end

# == Schema Information
#
# Table name: discourse_guild_levels
#
#  id                :integer          not null, primary key
#  active            :boolean          default(FALSE)
#  name       	     :text             not null
#  initial_payment   :decimal          default(0.00), precision(8), scale(2)
#  recurring         :boolean          default(FALSE)
#  recurring_payment :decimal          default(0.00), precision(8), scale(2)
#  trial             :boolean          default(FALSE)
#  trial_period      :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null