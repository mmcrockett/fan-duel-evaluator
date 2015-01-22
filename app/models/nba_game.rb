class NbaGame < ActiveRecord::Base
  extend NbaStat

  belongs_to :nba_player

  URI = "http://stats.nba.com/stats/playergamelog"
  RESULT_SET_IDENTIFIER = "PlayerGameLog"
  COLUMN_MAP = {
    "SEASON_ID"   => "season_id",
    "Player_ID"   => "nba_player_id",
    "Game_ID"     => "game_id",
    "GAME_DATE"   => "game_date",
    "MATCHUP"     => "matchup",
    "MIN"         => "minutes",
    "REB"         => "rebounds",
    "AST"         => "assists",
    "STL"         => "steals",
    "BLK"         => "blocks",
    "TOV"         => "turnovers",
    "PTS"         => "points",
  }
  URI_PARAMS = {
    "Season"           => "2014-15",
    "SeasonType"       => "Regular Season",
  }
  FAN_DUEL_POINTS = {
    "rebounds"  => 1.2,
    "assists"   => 1.5,
    "turnovers" => -1,
    "steals"    => 2,
    "blocks"    => 2,
    "points"    => 1,
  }

  def matchup=(matchup)
    if (true == matchup.include?("@"))
      teams = matchup.split("@")
      self.visitor = teams[0].strip
      self.home    = teams[1].strip
    elsif (true == matchup.include?("vs."))
      teams = matchup.split("vs.")
      self.visitor = teams[1].strip
      self.home    = teams[0].strip
    else
      raise "!ERROR: Unexpected matchup to parse '#{matchup}'."
    end
  end

  def fan_duel_points
    points = 0.0

    self.attributes.each do |column_name, value|
      if (true == FAN_DUEL_POINTS.include?(column_name))
        points += (FAN_DUEL_POINTS[column_name] * value)
      end
    end

    return points
  end

  def self.load
    games = []
    today = Date.today

    NbaPlayer.all.each do |player|
      NbaGame.get_data({"PlayerID" => player.id}).each do |game|
        if (false == NbaGame.exists?({:nba_player_id => player.id, :game_id => game["game_id"]}))
          ar_game = NbaGame.new(game)

          if (today != ar_game.game_date)
            games <<  NbaGame.new(game)
          end
        end
      end
    end

    NbaGame.import(games)
  end
end