class NbaTeam < NbaStat
  URI = "http://stats.nba.com/stats/leaguedashteamstats"
  RESULT_SET_IDENTIFIER = "LeagueDashTeamStats"
  COLUMN_MAP = {
    "TEAM_ID"    => "id",
    "TEAM_NAME"  => "name",
    "GP"         => "gp",
    "OFF_RATING" => "off_rating",
    "DEF_RATING" => "def_rating",
    "PACE"       => "pace",
  }
  URI_PARAMS = {
    "DateFrom"         => nil,
    "DateTo"           => nil,
    "GameScope"        => nil,
    "GameSegment"      => nil,
    "LastNGames"       => 0,
    "LeagueID"         => "00",
    "Location"         => nil,
    "MeasureType"      => "Advanced",
    "Month"            => 0,
    "OpponentTeamID"   => 0,
    "Outcome"          => nil,
    "PaceAdjust"       => "N",
    "PerMode"          => "Totals",
    "Period"           => 0,
    "PlayerExperience" => nil,
    "PlayerPosition"   => nil,
    "PlusMinus"        => "N",
    "Rank"             => "N",
    "Season"           => "2014-15",
    "SeasonSegment"    => nil,
    "SeasonType"       => "Regular+Season",
    "StarterBench"     => nil,
    "VsConference"     => nil,
    "VsDivision"       => nil
  }
end
