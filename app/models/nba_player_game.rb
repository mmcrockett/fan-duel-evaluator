class NbaPlayerGame < ActiveRecord::Base
  extend NbaStat

  belongs_to :nba_player
  belongs_to :nba_team_game

  URI = "http://stats.nba.com/stats/playergamelog"
  RESULT_SET_IDENTIFIER = "PlayerGameLog"
  COLUMN_MAP = {
    "SEASON_ID"   => "season_id",
    "Player_ID"   => "nba_player_id",
    "Game_ID"     => "nba_team_game_id",
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
      NbaPlayerGame.get_data({"PlayerID" => player.id}).each do |game|
        if (false == NbaPlayerGame.exists?({:nba_player_id => player.id, :game_id => game["game_id"]}))
          ar_game = NbaPlayerGame.new(game)

          if (today != ar_game.game_date)
            games <<  NbaPlayerGame.new(game)
          end
        end
      end
    end

    NbaPlayerGame.import(games)
  end
end
