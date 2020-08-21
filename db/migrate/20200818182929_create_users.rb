class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :nickname
      t.string :password_digest, null: false
      t.string :token
      t.boolean :admin, default: false, null: false
      t.integer :grade

      t.timestamps
      t.index :name, unique: true
      t.index :token, unique: true
    end
  end
end
