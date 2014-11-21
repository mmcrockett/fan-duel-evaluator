json.array!(@rosters) do |roster|
  json.extract! roster, :id, :players, :notes
end
