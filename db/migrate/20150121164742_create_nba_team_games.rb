class CreateNbaTeamGames < ActiveRecord::Migration
  def change
    create_table :nba_team_games do |t|
      t.string :game_id, :null => false
      t.date :game_date, :null => false
      t.string :visitor, :null => false
      t.string :home, :null => false
      t.integer :minutes, :null => false
      t.boolean :win, :null => false
      t.references :nba_team, index: true, :null => false

      t.timestamps
    end
  end
end
