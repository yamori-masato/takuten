class AddTitleToSingles < ActiveRecord::Migration[5.2]
  def change
    add_column :singles, :title, :string
  end
end
