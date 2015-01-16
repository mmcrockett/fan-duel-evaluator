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
end
