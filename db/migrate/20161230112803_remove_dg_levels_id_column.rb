class RemoveDgLevelsIdColumn < ActiveRecord::Migration
  def change
    remove_column :dg_levels, :dg_levels_id
  end
end