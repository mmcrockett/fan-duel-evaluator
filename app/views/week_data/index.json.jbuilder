json.array!(@week_data) do |week_datum|
  json.extract! week_datum, :id, :week, :fan_duel, :yahoo, :dvoa, :fftoday
end
