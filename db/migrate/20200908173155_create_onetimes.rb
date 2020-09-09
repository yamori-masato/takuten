class CreateOnetimes < ActiveRecord::Migration[5.2]
  def change
    create_table :onetimes do |t|
      t.date :date, null: false
      t.time :time_start, null: false
      t.time :time_end, null: false
      t.references :band, foreign_key: true
      t.string :type

      t.timestamps
    end
  end
end
