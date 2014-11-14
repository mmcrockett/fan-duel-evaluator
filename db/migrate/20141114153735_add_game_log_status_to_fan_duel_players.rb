class AddGameLogStatusToFanDuelPlayers < ActiveRecord::Migration
  def change
    add_column :fan_duel_players, :game_log_loaded, :boolean, :default => false
  end
end
