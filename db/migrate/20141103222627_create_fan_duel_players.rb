class CreateFanDuelPlayers < ActiveRecord::Migration
  def change
    create_table :fan_duel_players do |t|
      t.string :name, :null => false
      t.references :import, :null => false
      t.integer :player_id, :null => false
      t.integer :team_id, :null => false
      t.integer :game_id, :null => false
      t.string :position, :null => false
      t.decimal :average, :null => false, :precision => 4, :scale => 2
      t.integer :cost, :null => false
      t.string  :status, :default => ""
      t.string  :note, :default => ""
      t.boolean :ignore, :null => false, :default => false

      t.timestamps
    end
  end
end
