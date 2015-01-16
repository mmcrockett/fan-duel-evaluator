class CreateNbaGames < ActiveRecord::Migration
  def change
    create_table :nba_games do |t|
      t.string :season_id, :null => false
      t.string :game_id, :null => false
      t.date :game_date, :null => false
      t.string :visitor, :null => false
      t.string :home, :null => false
      t.integer :minutes, :null => false
      t.integer :points, :null => false
      t.integer :rebounds, :null => false
      t.integer :assists, :null => false
      t.integer :steals, :null => false
      t.integer :blocks, :null => false
      t.integer :turnovers, :null => false
      t.references :nba_player, index: true, :null => false

      t.timestamps
    end
  end
end
