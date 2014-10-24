class AddInjuryToFanDuelPlayers < ActiveRecord::Migration
  def change
    add_column :fan_duel_players, :status, :string, :default => ""
    add_column :fan_duel_players, :note, :string, :default => ""
    add_column :fan_duel_players, :ignore, :boolean, :null => false, :default => false
  end
end
