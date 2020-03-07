class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :name
      t.string :steamid
      t.boolean :vacban
      t.boolean :gameban
      t.boolean :familyshare
      t.integer :steamplaytime
      t.integer :serverplaytime
      t.integer :seasonplaytime
      t.string :connectip

      t.timestamps
    end
  end
end
