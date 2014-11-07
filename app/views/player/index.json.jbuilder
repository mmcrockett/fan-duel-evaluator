json.array!(@players) do |player|
  if (true == player.is_a?(NflPlayer))
    json.partial! 'nfl', player: player
  else
    json.extract! player, :id, :name, :position, :team, :opponent, :scoring, :average, :pavg, :cost, :pcost, :status
  end
end
