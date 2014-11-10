class AddGameDataToFanDuelPlayers < ActiveRecord::Migration
  def change
    add_column :fan_duel_players, :game_data, :string
  end
end
