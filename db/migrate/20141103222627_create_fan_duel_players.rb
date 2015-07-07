class CreateFanDuelPlayers < ActiveRecord::Migration
  def change
    create_table :fan_duel_players do |t|
      t.string  :fd_data, :null => false
      t.string  :game_data
      t.boolean :game_data_loaded, :default => false

      t.boolean :ignore, :null => false, :default => false

      t.references :import, :null => false

      t.timestamps
    end
  end
end
