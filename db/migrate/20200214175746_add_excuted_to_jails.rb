class AddExcutedToJails < ActiveRecord::Migration[5.2]
  def change
    add_column :jails, :executed, :boolean
  end
end
