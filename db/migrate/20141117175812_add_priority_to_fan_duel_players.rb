class AddPriorityToFanDuelPlayers < ActiveRecord::Migration
  def change
    add_column :fan_duel_players, :priority, :string, :default => ""
  end
end
