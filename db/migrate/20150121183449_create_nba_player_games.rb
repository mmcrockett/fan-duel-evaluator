class CreateNbaPlayerGames < ActiveRecord::Migration
  def change
    create_table :nba_player_games do |t|
      t.string :season_id, :null => false
      t.integer :minutes, :null => false
      t.integer :rebounds, :null => false
      t.integer :assists, :null => false
      t.integer :steals, :null => false
      t.integer :blocks, :null => false
      t.integer :turnovers, :null => false
      t.references :nba_player, index: true, :null => false
      t.references :nba_team_game, index: true, :null => false

      t.timestamps
    end
  end
end
