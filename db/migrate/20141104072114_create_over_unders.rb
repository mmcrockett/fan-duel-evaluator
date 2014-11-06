class CreateOverUnders < ActiveRecord::Migration
  def change
    create_table :over_unders do |t|
      t.decimal :overunder, :null => false, :precision => 4, :scale => 1
      t.decimal :home_spread, :null => false, :precision => 4, :scale => 1
      t.string :home, :null => false
      t.string :visitor, :null => false
      t.references :import, index: true

      t.timestamps
    end
  end
end
