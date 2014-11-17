require 'array_mod'
require 'open-uri'

class FanDuelPlayer < ActiveRecord::Base
  belongs_to :import
  serialize :game_data, JSON
  attr_accessor :team, :pavg, :pcost, :opp, :exp, :max, :min, :med, :mean, :rgms, :value, :rvalue, :pos, :avg, :opponent

  PLAYER_DETAIL_URL     = "https://www.fanduel.com/eg/Player/"
  PLAYER_DETAIL_URL_EXT = "/Stats/showLB/"
  DATE_FORMAT = "%m/%d/%Y"

  def avg
    return self.average
  end

  def pos
    return self.position
  end

  def rvalue
    if (0 != self.mean)
      recent_value = (self.cost/self.mean).to_i
    else
      recent_value = 0
    end

    if ((10000 <= recent_value) || (0 >= recent_value))
      return 9999
    else
      return recent_value
    end
  end

  def max
    return self.game_data.max || 0
  end

  def rgms
    return self.game_data.size || 0
  end

  def min
    return self.game_data.min || 0
  end

  def med
    return self.game_data.median || 0
  end

  def mean
    return self.game_data.mean.round(1)
  end

  def team
    return @team || "?"
  end

  def opponent
    return self.opp()
  end

  def opp
    return @opp || "?"
  end

  def pcost
    return @pcost || 0
  end

  def pavg
    return @pavg || 0
  end

  def exp
    return @exp || 0
  end

  def value
    if (nil == @value)
      if (0 != self.average)
        return (self.cost/self.average).to_i
      else
        return 0
      end
    else
      return @value.to_i
    end
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

  def self.factory(import)
    if ("NFL" == import.league)
      klazz = NflPlayer
    elsif ("NHL" == import.league)
      klazz = NhlPlayer
    elsif ("NBA" == import.league)
      klazz = NbaPlayer
    else
      raise "!ERROR: league type is unknown '#{import}'."
    end

    return klazz
  end

  def self.parse(data, import)
    players  = []
    json_obj = JSON.load(data)
    klazz    = FanDuelPlayer.factory(import)

    json_obj.each_pair do |player_id, player_data|
      player = klazz.player(player_data)
      player.player_id = player_id.to_i
      player.import_id = import.id

      if (true == player.important?())
        players << player
      end
    end

    FanDuelPlayer.import(players)
  end

  def self.player(player_data)
    added_note = ""
    priority   = player_data[11]

    if ("breaking" == priority)
      added_note = "*"
    elsif ("recent" == priority)
      added_note = "+"
    elsif ("old" == priority)
      added_note = "-"
    end

    return self.new({
      :name      => player_data[1],
      :team_id   => player_data[3].to_i,
      :game_id   => player_data[2].to_i,
      :position  => player_data[0],
      :average   => player_data[6].to_f,
      :cost      => player_data[5].to_i,
      :status    => "#{player_data[12]}#{added_note}",
      :note      => player_data[10],
      :game_data => [],
      :game_log_loaded => false
    })
  end

  def self.load_player_details(params = {})
    import = Import.where({:league => params[:league]}).last
    altered_players = []

    if ((nil != import) && (nil != import.fd_game_id))
      klazz = FanDuelPlayer.factory(import)

      klazz.where({:ignore => false, :import => import, :game_log_loaded => false}).each do |fd_player|
        if (true == fd_player.game_data.is_a?(Array))
          points = []
          uri  = "#{PLAYER_DETAIL_URL}#{fd_player.player_id}#{PLAYER_DETAIL_URL_EXT}#{import.fd_game_id}"
          cutoff_date = Date.today() - klazz::MAX_DATES
          begin
            page = Nokogiri::HTML(open("#{uri}"))
            page.css('table.game-log')[0].css('tbody')[0].css('tr').each_with_index do |tr,i|
              if (i < klazz::MAX_GAMES)
                tds = tr.css('td')
                date = Date.strptime("#{tds[0].text()}/#{Date.today.year}", DATE_FORMAT)

                if (date > Date.today)
                  date = date - 365
                end

                if (date > cutoff_date)
                  fantasy_points = tds[-1].text().to_f.round(2)
                  minutes        = tds[2].text().to_i

                  if ((0 != fantasy_points) || (minutes != 0))
                    points << tds[-1].text().to_f.round(2)
                  end
                end
              else
                break
              end
            end
            fd_player.game_data = points
            fd_player.game_log_loaded = true
            altered_players << fd_player
          rescue
            logger.warn "Couldn't load player '#{fd_player.name}' in import '#{fd_player.import_id}' - '#{uri}'"
          end
        else
          raise "!ERROR: #{fd_player.name} in import #{import.id} has non-array in game_data."
        end
      end
    end

    if (0 != altered_players.size)
      FanDuelPlayer.transaction do
        altered_players.each do |p|
          p.save
        end
      end
    end
  end

  def self.player_data(params = {})
    import = Import.where({:league => params[:league]}).last

    if (nil == import)
      return []
    end

    klazz = FanDuelPlayer.factory(import)

    players = []
    scores  = []
    overunders = {}

    OverUnder.where({:import => import}).each do |overunder|
      home    = OverUnder.translate(import.league, overunder[:home])
      visitor = OverUnder.translate(import.league, overunder[:visitor])

      if (overunder[:overunder] > overunder[:home_spread].abs)
        h_score = (overunder[:overunder] - overunder[:home_spread])/2
      else
        if (overunder[:home_spread] > 0)
          p_win = 100/(100+overunder[:home_spread])
        else
          p_win = -(overunder[:home_spread])/(100-overunder[:home_spread])
        end
        h_score = (overunder[:overunder]*p_win).round(2)
      end

      v_score = (overunder[:overunder] - h_score)
      overunders[home] = {:opp => visitor, :score => h_score}
      overunders[visitor] = {:opp => home, :score => v_score}

      if (0 != overunder[:overunder])
        scores << h_score
        scores << v_score
      end
    end

    klazz.where({:ignore => false, :import => import}).each do |fd_player|
      #fd_player_previous = FanDuelPlayer.where("import_id != ? AND player_id = ?", import.id, fd_player.player_id).last

      #if (nil != fd_player_previous)
        #fd_player.pcost = fd_player_previous.cost
        #fd_player.pavg  = fd_player_previous.average
      #end

      fd_player.team     = fd_player.team_name

      if (false == overunders.include?(fd_player.team_name))
        raise "!ERROR: OverUnder not defined for '#{fd_player.team_name}'."
      else
        fd_player.opp = overunders[fd_player.team_name][:opp]
      end

      if (false == overunders[fd_player.team_name].include?(:boost))
        overunders[fd_player.team_name][:boost] = OverUnder.calculate_boost(overunders[fd_player.team_name][:score], scores)
      end

      if (false == overunders[fd_player.opp].include?(:boost))
        overunders[fd_player.opp][:boost] = OverUnder.calculate_boost(overunders[fd_player.opp][:score], scores)
      end

      if ((("D" == fd_player.position) && ("NFL" == import.league)) || (("G" == fd_player.position) && ("NHL" == import.league)))
        fd_player.exp  = -overunders[fd_player.opp][:boost]
      else
        fd_player.exp  = overunders[fd_player.team_name][:boost]
      end

      players << fd_player
    end

    return players
  end
end
