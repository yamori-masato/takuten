class CreateExceptionTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :exception_times do |t|
      t.references :recurring, foreign_key: true, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
