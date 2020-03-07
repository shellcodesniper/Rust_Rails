class CreateJails < ActiveRecord::Migration[5.2]
  def change
	create_table :jails do |t|
	  t.string :server
      t.string :jailtype
      t.string :title
      t.string :targetid
      t.string :reason
      t.datetime :start_date
      t.datetime :end_date
      t.string :judger

      t.timestamps
    end
  end
end
