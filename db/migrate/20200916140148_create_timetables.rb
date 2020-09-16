class CreateTimetables < ActiveRecord::Migration[5.2]
  def change
    create_table :timetables do |t|
      t.date :date_start, null: false
      t.date :date_end
      t.text :sections, null: false

      t.timestamps
    end
  end
end
