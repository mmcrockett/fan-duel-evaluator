#Roster.analyze(true)
rosters = Roster.where({:week => WeekDatum.get_week(params)})

json.array!(rosters) do |d|
  json.roster("#{d.players_str()}")
  json.extract! d, :cost, :average, :dvoa
end
