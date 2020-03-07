class CreateCombatLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :combat_logs do |t|
      t.references :player, foreign_key: true
      t.integer :time
      t.string :attacker
      t.string :target
      t.string :weapon
      t.string :ammo
      t.string :area
      t.string :distance
      t.float :old_hp
      t.float :new_hp
      t.string :info

      t.timestamps
    end
  end
end
