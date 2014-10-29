namespace :fan_duel_evaluator do
  desc "Evaluate the best lineups."
  task(:analyze => :environment) do
    Roster.analyze({:debug => false, :k_d_ignore => false})
    Roster.analyze({:debug => false, :k_d_ignore => true})
  end
end

