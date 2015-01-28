class CreateNbaPlayers < ActiveRecord::Migration
  def change
    create_table :nba_players do |t|
      t.string :name, :null => false
      t.integer :assigned_player_id, :null => false
      t.references :nba_team, index: true, :null => false

      t.timestamps
    end
  end
end
