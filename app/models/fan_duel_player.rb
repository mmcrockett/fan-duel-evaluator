require 'array_mod'

class FanDuelPlayer < ActiveRecord::Base
  belongs_to :import
  attr_accessor :team, :pavg, :pcost, :opponent, :scoring

  def team
    return @team || "?"
  end

  def opponent
    return @opponent || "?"
  end

  def pcost
    return @pcost || 0
  end

  def pavg
    return @pavg || 0
  end

  def scoring
    return @scoring || 0
  end

  def self.team_id(team_name)
    return self::TEAMS_BY_FD_ID.key(team_name)
  end

  def team_name
    if (false == self.class::TEAMS_BY_FD_ID.include?(self.team_id))
      raise "!ERROR: team_id '#{self.team_id}' not defined in TEAMS_BY_FD_ID."
    end

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

    if (nil == import)
      return []
    end

    if ("NFL" == import.league)
      klazz = NflPlayer
    elsif ("NHL" == import.league)
      klazz = NhlPlayer
    elsif ("NBA" == import.league)
      klazz = NbaPlayer
    end

    players = []
    scores  = []
    overunders = {}

    OverUnder.where({:import => import}).each do |overunder|
      home    = OverUnder.translate(import.league, overunder[:home])
      visitor = OverUnder.translate(import.league, overunder[:visitor])
      puts "#{visitor}:#{home}"
      h_score = (overunder[:overunder] - overunder[:home_spread])/2
      v_score = (overunder[:overunder] - h_score)
      overunders[home] = {:opponent => visitor, :score => h_score}
      overunders[visitor] = {:opponent => home, :score => v_score}

      if (0 != overunder[:overunder])
        scores << h_score
        scores << v_score
      end
    end

    klazz.where({:ignore => false, :import => import}).each do |fd_player|
      fd_player_previous = FanDuelPlayer.where("import_id != ? AND player_id = ?", import.id, fd_player.player_id).last

      if (nil != fd_player_previous)
        fd_player.pcost = fd_player_previous.cost
        fd_player.pavg  = fd_player_previous.average
      end

      fd_player.team     = fd_player.team_name

      if (false == overunders.include?(fd_player.team_name))
        raise "!ERROR: OverUnder not defined for '#{fd_player.team_name}'."
      else
        fd_player.opponent = overunders[fd_player.team_name][:opponent]
      end

      if (false == overunders.include?(:boost))
        overunders[fd_player.team_name][:boost] = OverUnder.calculate_boost(overunders[fd_player.team_name][:score], scores)
      end

      if ("D" == fd_player.position)
        fd_player.scoring  = overunders[fd_player.opponent][:boost]
      else
        fd_player.scoring  = overunders[fd_player.team_name][:boost]
      end

      players << fd_player
    end

    return players
  end
end
