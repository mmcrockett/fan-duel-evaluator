json.array!(@rosters) do |roster|
  json.extract! roster, :notes

  json.players do |x|
    json.partial! 'players', players: roster.players
  end
end
