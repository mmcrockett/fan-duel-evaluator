class NbaPlayer < ActiveRecord::Base 
  extend NbaStat

  belongs_to :nba_team

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
