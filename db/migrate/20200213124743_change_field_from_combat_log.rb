class ChangeFieldFromCombatLog < ActiveRecord::Migration[5.2]
  def change
	remove_column :combat_logs, :ammo
	remove_column :combat_logs, :area
	remove_column :combat_logs, :old_hp
	remove_column :combat_logs, :new_hp
	remove_column :combat_logs, :time
	remove_column :combat_logs, :target

	add_column :combat_logs, :damage, :float

  end
end
