class NbaPlayerGame < ActiveRecord::Base
  extend NbaStat

  belongs_to :nba_player

  URI = "http://stats.nba.com/stats/playergamelog"
  RESULT_SET_IDENTIFIER = "PlayerGameLog"
  COLUMN_MAP = {
    "GAME_DATE" => "game_date_str",
    "MATCHUP"   => "matchup",
    "SEASON_ID" => "assigned_season_id",
    "Game_ID"   => "assigned_game_id",
    "MIN"       => "minutes",
    "REB"       => "rebounds",
    "AST"       => "assists",
    "STL"       => "steals",
    "BLK"       => "blocks",
    "TOV"       => "turnovers",
    "PTS"       => "points",
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

  def matchup=(matchup_str)
    matchups = NbaTeamGame.matchup_parse(matchup_str)

    self.visitor = matchups[:visitor]
    self.home    = matchups[:home]
  end

  def game_date_str=(game_date_str)
    self.game_date = Date.parse(game_date_str)
  end

  def self.remote_load
    player_games = []
    today = Date.today

    NbaPlayer.all.each do |player|
      most_recent_game_date = NbaPlayerGame.where({:nba_player_id => player.id}).maximum(:game_date)

      NbaPlayerGame.get_data({"PlayerID" => player.assigned_player_id}).each do |game|
        ar_game = NbaPlayerGame.new(game)
        ar_game.nba_player_id = player.id

        if ((today != ar_game.game_date) && ((nil == most_recent_game_date) || (most_recent_game_date < ar_game.game_date)))
          player_games << ar_game
        end
      end
    end

    NbaPlayerGame.import(player_games)
  end

  def self.actual_points(fd_players, verbose = false)
    points = 0

    fd_players.each do |fd_player|
      nba_player = NbaPlayer.lookup_by_fd_player(fd_player)

      if (nil == nba_player)
        if (true == verbose)
          puts "Couldn't find player for '#{fd_player.id}' '#{fd_player.name}' on '#{fd_player.created_at.to_date}'."
        end
      else
        nba_player_game = NbaPlayerGame.where("nba_player_id = ? AND game_date = ?", nba_player.id, fd_player.created_at.to_date).first

        if (nil == nba_player_game)
          if (true == verbose)
            puts "Couldn't find game for '#{nba_player.id}' '#{fd_player.name}' on '#{fd_player.created_at.to_date}'."
          end
        else
          points += nba_player_game.fan_duel_points
        end
      end
    end

    return points
  end

  def self.empty_game(params = {})
    defaults = {
      :game_date => "1969-01-01",
      :minutes => 0,
      :points => 0,
      :rebounds => 0,
      :assists => 0,
      :turnovers => 0,
      :steals => 0,
      :blocks => 0,
      :nba_player_id => -1
    }

    return self.new(defaults.merge(params))
  end
end
