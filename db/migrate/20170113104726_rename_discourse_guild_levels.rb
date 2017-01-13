class RenameDiscourseGuildLevels < ActiveRecord::Migration
  def change
    rename_table :discourse_guild_levels, :discourse_league_levels
  end 
end