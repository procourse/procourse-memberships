class CreateDgLevels < ActiveRecord::Migration
  def change
    create_table :dg_levels do |t|
      t.integer :dg_levels_id, null: false
      t.boolean :active, default: false
      t.text :name, null: false
      t.decimal :initial_payment, default: 0.00, precision: 8, scale: 2
      t.boolean :recurring, default: false
      t.decimal :recurring_payment, default: 0.00, precision: 8, scale: 2
      t.boolean :trial, default: false
      t.integer :trial_period, default: 0
      t.timestamps
    end
  end
end