json.array!(@players) do |player|
  json.extract! player, :id, :name, :position, :team, :opponent

  if (true == player.is_a?(NflPlayer))
    json.partial! 'nfl', player: player
  end

  json.extract! player, :scoring, :average, :ravg, :max, :median, :min, :rgames, :pavg, :cost, :value, :rvalue, :status
end
