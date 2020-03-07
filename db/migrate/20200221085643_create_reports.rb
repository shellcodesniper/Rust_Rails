class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :title
      t.string :reason
      t.text :content
      t.references :server, foreign_key: true
      t.references :player, foreign_key: true
      t.references :user, foreign_key: true
      t.text :memo

      t.timestamps
    end
  end
end
