class CreateYahoos < ActiveRecord::Migration
  def change
    create_table :yahoos do |t|
      t.string :team, :null => false
      t.integer :week, :null => false
      t.decimal :average, :null => false, :precision => 4, :scale => 2

      t.timestamps
    end
  end
end
