class CreateNbaTeams < ActiveRecord::Migration
  def change
    create_table :nba_teams do |t|
      t.string :name, :null => false
      t.integer :gp, :null => false
      t.integer :assigned_team_id, :null => false
      t.decimal :off_rating, :null => false, :precision => 4, :scale => 1
      t.decimal :def_rating, :null => false, :precision => 4, :scale => 1
      t.decimal :pace, :null => false, :precision => 4, :scale => 1

      t.timestamps
    end
  end
end
