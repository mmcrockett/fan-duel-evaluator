json.array!(@over_unders) do |over_under|
  json.extract! over_under, :team, :opp, :score, :opp_score, :diff
end
