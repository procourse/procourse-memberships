class CreateDiscourseGuildPages < ActiveRecord::Migration
  def change
    create_table :discourse_guild_pages do |t|
      t.boolean :active, default: false
      t.string :title, null: false
      t.text :slug, null: false
      t.text :raw, null: false
      t.text :cooked, null: false
      t.timestamps
    end
  end
end