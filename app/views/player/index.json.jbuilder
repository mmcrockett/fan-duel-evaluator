json.array!(FanDuelPlayer.player_data(params)) do |player|
  json.extract! player, :name, :position, :average, :pavg, :cost, :pcost, :status
end
