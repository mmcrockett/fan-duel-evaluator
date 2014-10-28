class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.integer :week, :null => false
      t.integer :cost, :null => false
      t.decimal :average, :null => false, :precision => 4, :scale => 2
      t.decimal :dvoa, :null => false, :precision => 4, :scale => 2
      t.string :players, :null => false

      t.timestamps
    end
  end
end
