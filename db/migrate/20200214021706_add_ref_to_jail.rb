class AddRefToJail < ActiveRecord::Migration[5.2]
  def change
	remove_column :jails, :targetid
	add_reference :jails, :player, foreign_key: true
  end
end
