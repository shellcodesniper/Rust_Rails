class CreateCrons < ActiveRecord::Migration[5.2]
  def change
    create_table :crons do |t|
      t.string :job
	  t.datetime :next
	  t.integer :duration
      t.text :memo

      t.timestamps
    end
  end
end
