class NflPlayer < FanDuelPlayer
  attr_accessor :dvoa

  TEAMS_BY_FD_ID = {
    1 => "NYJ",
    2 => "MIA",
    3 => "NE",
    4 => "BUF",
    5 => "PIT",
    6 => "BAL",
    7 => "CLE",
    8 => "CIN",
    9 => "TEN",
    10 => "IND",
    11 => "HOU",
    12 => "JAC",
    13 => "DEN",
    14 => "SD",
    15 => "OAK",
    16 => "KC",
    17 => "NYG",
    18 => "DAL",
    19 => "PHI",
    20 => "WAS",
    21 => "MIN",
    22 => "CHI",
    23 => "GB",
    24 => "DET",
    25 => "CAR",
    26 => "TB",
    27 => "ATL",
    28 => "NO",
    29 => "ARI",
    30 => "SF",
    31 => "SEA",
    32 => "STL"
  }

  def dvoa
    return @dvoa || 0
  end

  def self.player_data(params)
    players = FanDuelPlayer.player_data(params)

    players.each do |player|
      player.dvoa = (Dvoa.adjustment(player.import_id, player.position, player.opponent)).round(2)
    end

    return players
  end
end
