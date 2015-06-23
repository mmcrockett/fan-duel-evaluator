class AddNotesDropNoteToFanDuelPlayers < ActiveRecord::Migration
  def change
    add_column :fan_duel_players, :notes, :string
    remove_column :fan_duel_players, :note
  end
end
