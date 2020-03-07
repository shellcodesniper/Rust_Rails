class CreateServers < ActiveRecord::Migration[5.2]
  def change
    create_table :servers do |t|
      t.string :title
      t.string :rcon_host
      t.integer :rcon_port
      t.string :rcon_pass
      t.text :memo

      t.timestamps
    end
  end
end
