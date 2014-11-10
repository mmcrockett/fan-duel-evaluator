class AddFanDuelGameIdToImports < ActiveRecord::Migration
  def change
    add_column :imports, :fd_game_id, :integer
  end
end
