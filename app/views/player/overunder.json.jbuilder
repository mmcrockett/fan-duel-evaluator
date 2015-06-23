json.array!(@expected_scores) do |escore|
  json.extract! escore, :team, :opp, :exp_score, :exp_opp_score, :diff, :mult
end
