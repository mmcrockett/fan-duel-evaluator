json.array!(players) do |player|
  json.extract! player, :id, :name, :pos, :team, :opp

  if (true == player.is_a?(NflPlayer))
    json.partial! 'nfl', player: player
  end

  #json.extract! player, :exp, :avg, :mean, :max, :med, :min, :rgms, :cost, :value, :rvalue, :comment
  #json.extract! player, :exp, :avg, :mean, :max, :med, :min, :rgms, :last, :cost, :rvalue, :comment
  #json.extract! player, :proj, :expavg, :expmean, :avg, :med, :rgms, :last, :cost, :rvalue, :comment, :ignore
  json.extract! player, :proj, :fppg, :mean, :expmean, :news, :ignore
end
