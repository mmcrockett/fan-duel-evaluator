class NbaTeamGame < ActiveRecord::Base
  extend NbaStat

  belongs_to :nba_team

  URI = "http://stats.nba.com/stats/teamgamelog"
  RESULT_SET_IDENTIFIER = "TeamGameLog"
  COLUMN_MAP = {
    "Game_ID"   => "assigned_game_id",
    "GAME_DATE" => "game_date_str",
    "MATCHUP"   => "matchup",
    "WL"        => "winloss",
    "MIN"       => "minutes",
  }
  URI_PARAMS = {
    "Season"     => "2014-15",
    "SeasonType" => "Regular Season",
    "LeagueID"   => "00"
  }

  def matchup=(matchup_str)
    matchups = NbaTeamGame.matchup_parse(matchup_str)

    self.visitor = matchups[:visitor]
    self.home    = matchups[:home]
  end

  def game_date_str=(game_date_str)
    self.game_date = Date.parse(game_date_str)
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

  def self.remote_load
    team_games = []
    today = Date.today

    NbaTeam.all.each do |team|
      most_recent_game_date = NbaTeamGame.where({:nba_team_id => team.id}).maximum(:game_date)

      NbaTeamGame.get_data({"TeamID" => team.assigned_team_id}).each do |team_game|
        ar_game = NbaTeamGame.new(team_game)
        ar_game.nba_team_id = team.id

        if ((today != ar_game.game_date) && ((nil == most_recent_game_date) || (most_recent_game_date < ar_game.game_date)))
          team_games <<  ar_game
        end
      end
    end

    NbaTeamGame.import(team_games)
  end
end
