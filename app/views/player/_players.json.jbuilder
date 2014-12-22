json.array!(players) do |player|
  json.extract! player, :id, :name, :pos, :team, :opp

  if (true == player.is_a?(NflPlayer))
    json.partial! 'nfl', player: player
  end

  #json.extract! player, :exp, :avg, :mean, :max, :med, :min, :rgms, :cost, :value, :rvalue, :comment
  json.extract! player, :exp, :avg, :max, :med, :min, :rgms, :cost, :rvalue, :comment
end
