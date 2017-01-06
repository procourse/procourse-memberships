class AddDgLevelsGroupColumn < ActiveRecord::Migration
  def change
    add_column :discourse_guild_levels, :group, :integer
  end
end