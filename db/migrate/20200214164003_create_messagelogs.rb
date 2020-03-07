class CreateMessagelogs < ActiveRecord::Migration[5.2]
  def change
    create_table :messagelogs do |t|
      t.datetime :time
      t.references :player, foreign_key: true
      t.text :message
      t.references :server, foreign_key: true
      t.text :memo

      t.timestamps
    end
  end
end
