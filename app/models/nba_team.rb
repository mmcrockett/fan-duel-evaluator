class NbaTeam < ActiveRecord::Base
  extend NbaStat

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
    "SeasonType"       => "Regular Season",
    "StarterBench"     => nil,
    "VsConference"     => nil,
    "VsDivision"       => nil
  }

  def self.load
    teams  = []
    ateams = []

    NbaTeam.get_data.each do |team|
      ar_team = NbaTeam.where({:id => team['id']}).first_or_create(team)

      if (false == ar_team.new_record?())
        ar_team.update(team)
        ateams << ar_team
      else
        teams << ar_team
      end
    end

    NbaTeam.import(teams)

    if (0 != ateams)
      NbaTeam.transaction do
        ateams.each do |ateam|
          ateam.save
        end
      end
    end
  end
end
