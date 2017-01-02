class ChangeDgLevelsActive < ActiveRecord::Migration
  def change
    rename_column :discourse_guild_levels, :active, :enabled
  end
end