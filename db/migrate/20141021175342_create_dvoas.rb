class CreateDvoas < ActiveRecord::Migration
  def change
    create_table :dvoas do |t|
      t.string :team, :null => false
      t.integer :week, :null => false
      t.string :role, :null => false
      t.string :subrole, :null => false
      t.decimal :value, :null => false, :precision => 4, :scale => 2

      t.timestamps
    end
  end
end
