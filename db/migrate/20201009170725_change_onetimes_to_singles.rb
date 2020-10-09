class ChangeOnetimesToSingles < ActiveRecord::Migration[5.2]
  def change
    rename_table :onetimes, :singles
  end
end
