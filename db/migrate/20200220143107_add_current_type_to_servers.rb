class AddCurrentTypeToServers < ActiveRecord::Migration[5.2]
  def change
    add_column :servers, :current_reset_type, :integer
  end
end
