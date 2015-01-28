class NbaTeam < ActiveRecord::Base
  extend NbaStat

  URI = "http://stats.nba.com/stats/leaguedashteamstats"
  RESULT_SET_IDENTIFIER = "LeagueDashTeamStats"
  COLUMN_MAP = {
    "TEAM_ID"    => "assigned_team_id",
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
  NICKNAMES = {
    "Atlanta Hawks"          => "ATL",
    "Boston Celtics"         => "BOS",
    "Brooklyn Nets"          => "BKN",
    "Charlotte Hornets"      => "CHA",
    "Chicago Bulls"          => "CHI",
    "Cleveland Cavaliers"    => "CLE",
    "Dallas Mavericks"       => "DAL",
    "Denver Nuggets"         => "DEN",
    "Detroit Pistons"        => "DET",
    "Golden State Warriors"  => "GSW",
    "Houston Rockets"        => "HOU",
    "Indiana Pacers"         => "IND",
    "Los Angeles Clippers"   => "LAC",
    "Los Angeles Lakers"     => "LAL",
    "Memphis Grizzlies"      => "MEM",
    "Miami Heat"             => "MIA",
    "Milwaukee Bucks"        => "MIL",
    "Minnesota Timberwolves" => "MIN",
    "New Orleans Pelicans"   => "NOP",
    "New York Knicks"        => "NYK",
    "Oklahoma City Thunder"  => "OKC",
    "Orlando Magic"          => "ORL",
    "Philadelphia 76ers"     => "PHI",
    "Phoenix Suns"           => "PHX",
    "Portland Trail Blazers" => "POR",
    "Sacramento Kings"       => "SAC",
    "San Antonio Spurs"      => "SAS",
    "Toronto Raptors"        => "TOR",
    "Utah Jazz"              => "UTA",
    "Washington Wizards"     => "WAS",
  }

  def nickname
    if (true == NICKNAMES.include?(self.name))
      return NICKNAMES[self.name]
    else
      raise "!ERROR: No nickname defined for '#{self.name}'."
    end
  end

  def self.remote_load
    teams  = []
    ateams = []

    NbaTeam.get_data.each do |team|
      ar_team = NbaTeam.where({:assigned_team_id => team['assigned_team_id']}).first_or_create(team)

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
