class CreateBroadcasts < ActiveRecord::Migration[5.2]
  def change
    create_table :broadcasts do |t|
      t.string :title
      t.string :content
	  t.integer :duration

	  t.datetime :next
	  
	  t.references :server, foreign_key: true

      t.timestamps
    end
  end
end
