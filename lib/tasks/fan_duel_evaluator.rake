namespace :fan_duel_evaluator do
  desc "Evaluate the best lineups."
  task(:analyze => :environment) do
    Roster.analyze()
  end
end

