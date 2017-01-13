class RenameDiscourseGuildPages < ActiveRecord::Migration
  def change
    rename_table :discourse_guild_pages, :discourse_league_pages
  end 
end