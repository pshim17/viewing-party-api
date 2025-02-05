class CreateViewingParties < ActiveRecord::Migration[7.1]
  def change
    create_table :viewing_parties do |t|
      t.integer :movie_id
      t.integer :host_id
      t.date :date
      t.time :time

      t.timestamps
    end
  end
end
