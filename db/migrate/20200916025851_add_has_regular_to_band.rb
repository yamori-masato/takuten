class AddHasRegularToBand < ActiveRecord::Migration[5.2]
  def change
    add_column :bands, :has_regular, :boolean, default: false, null: false
  end
end
