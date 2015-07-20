require 'array_mod'
require 'open-uri'

class FanDuelPlayer < ActiveRecord::Base
  belongs_to :import

  serialize :game_data, JSON
  serialize :fd_data, JSON

  attr_accessor :opp, :value, :exp, :expmult

  @@most_recent_game = {}
  @@overunderset     = nil

  PLAYER_DETAIL_URL     = "https://www.fanduel.com/eg/Player/"
  PLAYER_DETAIL_URL_EXT = "/Stats/getPlayerData/"
  INF_VALUE   = 9999
  MINIMUM_UPDATE_TIME   = 60*30

  ANALYZE_COLUMNS = [:med, :p80]

  def player_id
    return self.fd_data['id']
  end

  def disabled?
    return self.fd_data['injured']
  end

  def starting?
    starting_order = self.fd_data['starting_order']

    if (nil == starting_order)
      return nil
    elsif (0 < starting_order.to_i)
      return true
    else
      return false
    end
  end

  def pos
    return self.fd_data['position']
  end

  def fppg
    fppg = self.fd_data['fppg']

    if (nil != fppg)
      return fppg.round(2)
    end

    return -999
  end

  def cost
    return self.fd_data['salary']
  end

  def team_id
    return self.fd_data['team']['_members'][0].to_i
  end

  def first_name
    return self.fd_data['first_name']
  end

  def last_name
    return self.fd_data['last_name']
  end

  def name
    return "#{self.first_name} #{self.last_name}"
  end

  def team_name
    if (false == self.class::TEAMS_BY_FD_ID.include?(self.team_id))
      raise "!ERROR: team_id '#{self.team_id}' not defined in TEAMS_BY_FD_ID."
    end

    return self.class::TEAMS_BY_FD_ID[self.team_id]
  end

  def opp
    if (nil != @@overunderset)
      return @@overunderset.get_opponent(self.team_name)
    end

    return "?"
  end

  def exp(col = "fppg", round = 1)
    if (false == self.send(col).is_a?(Numeric))
      raise "!ERROR: Can't perform expectation on non-numeric column - '#{col}' - '#{self.send(col).class}'."
    end

    return (self.send(col) * self.team_exp(:adjustment)).round(round)
  end

  def expmean
    return self.exp(:mean)
  end

  def team_exp(format = :percentage)
    if (nil != @@overunderset)
      return @@overunderset.multiplier(self.team_name, {:output => format, :defensive => self.defensive?})
    end

    return 0
  end

  def med
    return self.fpoints.median.round(1) || 0
  end

  def fpoints
    fpoints = []

    self.game_data.each do |gdata|
      gd = GameData.new(gdata)

      fpoints << gd.fp
    end

    return fpoints
  end

  def mean
    return self.fpoints[0,3].mean.round(1)
  end

  def news
    return self.fd_data["news"]
  end

  def news=(value)
    self.fd_data["news"]["summary"] = value
  end

  def p80
    self.fpoints.tolerance().round(1)
  end

  def last
    if ((nil != self.last_game_date) && (true == @@most_recent_game.include?(self.team)))
      return (@@most_recent_game[self.team] == self.last_game_date)
    else
      return nil
    end
  end

  def last_game_date
    if ((true == self.game_data_loaded) && (0 < self.game_data.size))
      return self.game_data[0]["date"]
    else
      return nil
    end
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
    return self.fpoints.max || 0
  end

  def rgms
    return self.fpoints.size || 0
  end

  def min
    return self.fpoints.min || 0
  end

  def value
    if (nil == @value)
      if (0 != self.fppg)
        return (self.cost/self.fppg).to_i
      else
        return INF_VALUE
      end
    else
      return @value.to_i
    end
  end

  def self.team_id(team_name)
    return self::TEAMS_BY_FD_ID.key(team_name)
  end

  def self.factory(import)
    if ("NFL" == import.league)
      klazz = NflPlayer
    elsif ("NHL" == import.league)
      klazz = NhlPlayer
    elsif ("NBA" == import.league)
      klazz = FanDuelNbaPlayer
    elsif ("CBB" == import.league)
      klazz = CollegeBasketballPlayer
    elsif ("MLB" == import.league)
      klazz = MlbPlayer
    else
      raise "!ERROR: league type is unknown '#{import}'."
    end

    return klazz
  end

  def self.parse(json_data, import)
    players  = []
    klazz    = FanDuelPlayer.factory(import)

    json_data.each do |player_data|
      player = klazz.player(player_data)
      player.import_id = import.id

      if (true == player.ignore?())
        player.ignore = true
      end

      players << player
    end

    FanDuelPlayer.import(players)
  end

  def self.player(player_json)
    return self.new({:fd_data => player_json, :game_data => [], :game_data_loaded => false})
  end

  def self.load_player_details(params = {})
    import = Import.latest_by_league(params)
    altered_players = []

    if ((nil != import) && (nil != import.fd_contest_id))
      klazz = FanDuelPlayer.factory(import)

      klazz.where({:import => import, :ignore => false}).each do |fd_player|
        if ((false == fd_player.game_data_loaded) || (DateTime.now > fd_player.updated_at + FanDuelPlayer::MINIMUM_UPDATE_TIME))
          points = []
          uri  = "#{PLAYER_DETAIL_URL}#{fd_player.player_id}#{PLAYER_DETAIL_URL_EXT}#{import.fd_contest_id}"
          cutoff_date = Date.today() - klazz::MAX_DATES
          begin
            details = JSON.parse(open("#{uri}", {}).read())
            
            fd_player.game_data = FanDuelPlayer.parse_player_details(details["player"]["gamestats"], klazz::MAX_GAMES, cutoff_date)
            fd_player.game_data_loaded = true
            fd_player.news = FanDuelPlayer.parse_player_news(details)

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

  def self.parse_player_news(data)
    if (false == data.include?("news"))
      raise "Unexpected news data - expected 'news' key found these keys - '#{data.class}':'#{data.keys}'."
    end

    news_data = data["news"]

    if (false == news_data.include?("items"))
      raise "Unexpected player news data - expected 'items' key found these keys - '#{news_data.class}':'#{news_data.keys}'."
    end

    news_data["items"].each do |news_item|
      return news_item["summary"]
    end

    return nil
  end

  def self.parse_player_details(game_data, max, cutoff_date)
    modified_game_data = []

    game_data.each_with_index do |game, i|
      if (i < max)
        game_data = GameData.new(game)

        if (cutoff_date < game_data.date)
          modified_game_data << game_data
        end
      else
        break
      end
    end

    return modified_game_data
  end

  def self.sort(players, sort_column, ascending = nil)
    sorted_players = players.sort_by do |p|
      if ((0 != p.send(sort_column)) && (true == p.send(sort_column).is_a?(Numeric)))
        p.value = p.cost/p.send(sort_column)
      elsif ((0 != p.fppg) && (false == p.send(sort_column).is_a?(Numeric)))
        p.value = p.cost/p.fppg
      else
        p.value = INF_VALUE
      end

      if ((nil == ascending) && (true == p.send(sort_column).is_a?(Numeric)))
        ascending = false
      end

      p.send(sort_column)
    end

    if (false == ascending)
      return sorted_players.reverse
    else
      return sorted_players
    end
  end

  def self.player_data(params = {})
    if (nil != params[:league])
      return FanDuelPlayer.get_players(params)
    end
  end

  def self.get_players(params = {})
    import = Import.latest_by_league(params[:league])

    if (nil == import)
      @@overunderset = nil
      return []
    end

    klazz = FanDuelPlayer.factory(import)

    if (true == OverUnder::URLS.include?(import.league))
      if ((nil == @@overunderset) || (import.id != @@overunderset.import_id))
        @@overunderset = OverUnderSet.new(import)
      end
    end

    players = []

    klazz.where({:import => import}).each do |fd_player|
      FanDuelPlayer.extract_latest_game(fd_player)

      if (false == params.include?(:ignore))
        players << fd_player
      elsif (params[:ignore] == fd_player.ignore)
        players << fd_player
      end
    end

    return players
  end

  def defensive?
    return false
  end

  def self.extract_latest_game(fd_player)
    if (nil != fd_player.last_game_date)
      if ((false == @@most_recent_game.include?(fd_player.team_name)) ||  (@@most_recent_game[fd_player.team_name] < fd_player.last_game_date))
        @@most_recent_game[fd_player.team_name] = fd_player.last_game_date
      end 
    end

    return @@most_recent_game
  end

  def to_s
    return "#{self.name}"
  end

  alias :team :team_name
  alias :proj :team_exp
  alias :expavg :exp
  alias :avg :fppg
end
