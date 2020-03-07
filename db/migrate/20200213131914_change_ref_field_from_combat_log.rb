class ChangeRefFieldFromCombatLog < ActiveRecord::Migration[5.2]
  def change
	remove_column :combat_logs, :attacker

	add_reference :combat_logs, :attacker, foreign_key: true
  end
end
