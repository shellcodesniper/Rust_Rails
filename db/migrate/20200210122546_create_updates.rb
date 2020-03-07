class CreateUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :updates do |t|
      t.string :title
	  t.text :content
	  
	  t.boolean :deleted, default: false

	  t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
	  t.datetime :modified_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
  end
end
