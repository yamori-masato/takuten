class CreateBands < ActiveRecord::Migration[5.2]
  def change
    create_table :bands do |t|
      t.string :name, null: false

      t.timestamps
      t.index :name, unique: true
    end
  end
end
