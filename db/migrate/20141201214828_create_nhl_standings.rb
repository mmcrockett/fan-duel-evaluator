class CreateNhlStandings < ActiveRecord::Migration
  def change
    create_table :nhl_standings do |t|
      t.string :team, :null => false
      t.references :import, index: true
      t.integer :games, :null => false
      t.integer :goals_scored, :null => false
      t.integer :goals_allowed, :null => false

      t.timestamps
    end
  end
end
