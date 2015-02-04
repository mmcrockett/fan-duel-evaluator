class NbaPlayer < ActiveRecord::Base 
  extend NbaStat

  belongs_to :nba_team
  has_many :nba_player_game

  URI = "http://stats.nba.com/stats/commonteamroster"
  RESULT_SET_IDENTIFIER = "CommonTeamRoster"
  COLUMN_MAP = {
    "PLAYER_ID" => "assigned_player_id",
    "PLAYER"    => "name",
  }
  URI_PARAMS = {
    "Season"   => "2014-15",
    "LeagueID" => "00"
  }
  MAX_RECENT_GAMES = 10

  def game_data
    data = []
    expected_dates = self.nba_team.nba_team_game.order(:game_date => :desc).limit(MAX_RECENT_GAMES).pluck(:game_date)
    teams = [self.nba_team.nickname]

    self.nba_player_game.order(:game_date => :desc).limit(MAX_RECENT_GAMES).each do |game|
      if ((game.visitor != teams[-1]) && (game.home != teams[-1]))
        teams <<  self.find_previous_team(teams)
        old_team = NbaTeam.where({:name => NbaTeam.team_name(teams[-1])}).first
        #ActiveRecord::Base.logger = Logger.new(STDOUT)
        #str = "#{old_team.nba_team_game.pluck(:game_date)}"
        #ActiveRecord::Base.logger = nil
        expected_dates = old_team.nba_team_game.where("game_date <= ?", game.game_date).order(:game_date => :desc).limit(MAX_RECENT_GAMES).pluck(:game_date)
      end

      while ((expected_dates[0] != game.game_date) && (0 != expected_dates.size))
        data << 0
        expected_dates.shift
      end

      if (0 != expected_dates.size)
        data << game.fan_duel_points
        expected_dates.shift
      end
    end

    return data[0,10]
  end

  def find_previous_team(known_teams)
    query = <<-EOS
      select team, count(1) as cnt
      from (
        select visitor as team
        from
        nba_player_games
        where
        nba_player_id = :player_id
        union all
        select home as team
        from
        nba_player_games
        where
        nba_player_id = :player_id)
      where
      team not in (:known_teams)
      group by team
      order by cnt desc
      limit 1
    EOS

    retval = NbaPlayerGame.find_by_sql([query, {:player_id => self.id, :known_teams => known_teams}]).first

    return retval["team"]
  end

  def self.remote_load
    players  = []
    aplayers = []

    NbaTeam.all.each do |team|
      NbaPlayer.get_data({"TeamID" => team.assigned_team_id}).each do |player|
        ar_player = NbaPlayer.where({:assigned_player_id => player['assigned_player_id']}).first_or_initialize()
        ar_player.attributes = player.merge({:nba_team_id => team.id})

        if (false == ar_player.new_record?())
          aplayers << ar_player
        else
          players << ar_player
        end
      end
    end

    NbaPlayer.import(players)

    NbaPlayer.transaction do
      aplayers.each do |aplayer|
        aplayer.save
      end
    end
  end

  def self.lookup_by_fd_player(fd_player)
    players = NbaPlayer.where("name = ?", fd_player.name)

    if (0 == players.size)
      players = NbaPlayer.where("name = ?", fd_player.name.delete("."))

      if (0 == players.size)
        players = NbaPlayer.where("name LIKE ?", "%#{fd_player.name.split(" ")[-1]}")
      end
    end

    if (1 == players.size)
      return players.first
    else
      return nil
    end
  end
end
