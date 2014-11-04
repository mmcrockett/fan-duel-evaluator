class FanDuelPlayer < ActiveRecord::Base
  belongs_to :import

  OVERUNDER_URL = "http://sports.yahoo.com/nba/odds/pointspread"

  def pavg
    return @pavg || 0
  end

  def pcost
    return @pcost || 0
  end

  def pavg=(v)
    @pavg = v
  end

  def pcost=(v)
    @pcost = v
  end

  def self.team_id(team_name)
    return self::TEAMS_BY_FD_ID.key(team_name)
  end

  def team_name
    return self.class::TEAMS_BY_FD_ID[self.team_id]
  end

  def self.parse(data, import)
    players  = []
    json_obj = JSON.load(data)

    json_obj.each_pair do |player_id, player_data|
      player = FanDuelPlayer.player(player_data)
      player.player_id = player_id.to_i
      player.import_id = import.id

      if ((0 < player.average) || ("D" == player.position))
        players << player
      end
    end

    FanDuelPlayer.import(players)
  end

  def self.player(player_data)
    return FanDuelPlayer.new({
      :name      => player_data[1],
      :team_id   => player_data[3].to_i,
      :game_id   => player_data[2].to_i,
      :position  => player_data[0],
      :average   => player_data[6].to_f,
      :cost      => player_data[5].to_i,
      :status    => player_data[12],
      :note      => player_data[10]
    })
  end

  def self.player_data(params = {})
    import = Import.where({:league => params[:league]}).last

    return FanDuelPlayer.where({:ignore => false, :import => import})
    players = []

    FanDuelPlayer.where("ignore = ? AND created_at >= ?", false, Date.today).each do |fd_player|
      fd_player_previous = FanDuelPlayer.find_by("created_at < ? and name = ?", Date.today, fd_player.name)

      if (nil != fd_player_previous)
        fd_player.pcost = fd_player_previous.cost
        fd_player.pavg  = fd_player_previous.average
      end

      players << fd_player
    end

    return players
  end
end
