class NbaPlayer < ActiveRecord::Base 
  extend NbaStat

  belongs_to :nba_team

  URI = "http://stats.nba.com/stats/teamplayerdashboard"
  RESULT_SET_IDENTIFIER = "PlayersSeasonTotals"
  COLUMN_MAP = {
    "PLAYER_ID"    => "id",
    "PLAYER_NAME"  => "name",
  }
  URI_PARAMS = {
    "DateFrom"         => nil,
    "DateTo"           => nil,
    "GameSegment"      => nil,
    "LastNGames"       => 0,
    "Location"         => nil,
    "MeasureType"      => "Advanced",
    "Month"            => 0,
    "OpponentTeamID"   => 0,
    "Outcome"          => nil,
    "PaceAdjust"       => "N",
    "PerMode"          => "Totals",
    "Period"           => 0,
    "PlusMinus"        => "N",
    "Rank"             => "N",
    "Season"           => "2014-15",
    "SeasonSegment"    => nil,
    "SeasonType"       => "Regular Season",
    "VsConference"     => nil,
    "VsDivision"       => nil
  }
end
