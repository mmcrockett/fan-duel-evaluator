class NbaTeamGame < ActiveRecord::Base
  extend NbaStat

  belongs_to :nba_team

  URI = "http://stats.nba.com/stats/teamgamelog"
  RESULT_SET_IDENTIFIER = "TeamGameLog"
  COLUMN_MAP = {
    "Team_ID"   => "nba_team_id",
    "Game_ID"   => "game_id",
    "GAME_DATE" => "game_date",
    "MATCHUP"   => "matchup",
    "WL"        => "winloss",
    "MIN"       => "minutes",
  }
  URI_PARAMS = {
    "Season"     => "2014-15",
    "SeasonType" => "Regular Season",
    "LeagueID"   => "00"
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

  def winloss=(v)
    if (true == v.is_a?(String))
      if ("W" == v)
        self.win = true
      elsif ("L" == v)
        self.win = false
      else
        raise "!ERROR: Win/Lose not 'W' or 'L': '#{v}'"
      end
    end
  end

  def self.load
    team_games = []
    today = Date.today

    NbaTeam.all.each do |team|
      NbaTeamGame.get_data({"TeamID" => player.id}).each do |team_game|
        if (false == NbaTeamGame.exists?({:nba_team_id => team.id, :game_id => team_game["game_id"]}))
          ar_game = NbaTeamGame.new(team_game)

          if (today != ar_game.game_date)
            team_games <<  ar_game
          end
        end
      end
    end

    NbaTeamGame.import(team_games)
  end
end
