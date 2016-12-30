class RenameDgLevels < ActiveRecord::Migration
   def change
     rename_table :dg_levels, :discourse_guild_levels
   end 
 end