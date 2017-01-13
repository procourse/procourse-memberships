class AddDiscourseLeaguePagesCustomSlugColumn < ActiveRecord::Migration
  def change
    add_column :discourse_league_pages, :custom_slug, :boolean, default: false
  end
end