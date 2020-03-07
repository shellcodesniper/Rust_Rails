class AddServerRefToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_reference :players, :server, foreign_key: true
  end
end
