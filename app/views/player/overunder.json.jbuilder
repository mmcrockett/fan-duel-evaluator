json.array!(@expected_scores) do |escore|
  json.extract! escore, :team, :opp, :score, :mult
end
