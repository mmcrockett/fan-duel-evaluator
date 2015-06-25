require 'array_mod'
require 'open-uri'

class FanDuelPlayer < ActiveRecord::Base
  belongs_to :import
  serialize :game_data, JSON
  serialize :notes, JSON
  attr_accessor :team, :opp, :exp, :expavg, :expmean, :expmed, :max, :min, :med, :mean, :rgms, :value, :rvalue, :pos, :avg, :opponent, :comment, :last, :p80

  @@overunders = nil
  @@most_recent_game = {}

  PLAYER_DETAIL_URL     = "https://www.fanduel.com/eg/Player/"
  PLAYER_DETAIL_URL_EXT = "/Stats/showLB/"
  DATE_FORMAT = "%m/%d/%Y"
  INF_VALUE   = 9999

  ANALYZE_COLUMNS = [:med, :p80]

  def p80
    self.fpoints.tolerance().round(1)
  end

  def last
    if ((nil != self.last_game_date) && (true == @@most_recent_game.include?(self.team)))
      return (@@most_recent_game[self.team] == self.last_game_date)
    else
      return false
    end
  end

  def last_game_date
    if ((true == self.game_log_loaded) && (0 < self.game_data.size))
      return self.game_data[0]["date"]
    else
      return nil
    end
  end

  def avg
    return self.average
  end

  def pos
    return self.position
  end

  def comment
    comment = ""

    if (1 < self.status.length)
      comment += "#{self.status}"

      if ("breaking" == priority)
        comment += "*"
      elsif ("recent" == priority)
        comment += "+"
      elsif ("old" == priority)
        comment += "o"
      end
    end

    self.notes.each_with_index do |v,i|
      if (0 != i)
        comment += " - "
      end

      comment += "#{v}"
    end

    return comment
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

  def med
    return self.fpoints.median.round(1) || 0
  end

  def mean
    return self.fpoints[0,3].mean.round(1)
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

  def exp
    return @exp || 0
  end

  def expmed
    return @expmed || 0
  end

  def expavg
    return @expavg || 0
  end

  def expmean
    return @expmean || 0
  end

  def value
    if (nil == @value)
      if (0 != self.average)
        return (self.cost/self.average).to_i
      else
        return INF_VALUE
      end
    else
      return @value.to_i
    end
  end

  def fpoints
    fpoints = []

    self.game_data.each do |gdata|
      if (true == gdata.is_a?(Hash))
        fpoints << gdata["fpoints"]
      else
        fpoints << gdata
      end
    end

    return fpoints
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

  def self.parse(data, import)
    players  = []
    json_obj = JSON.load(data)
    klazz    = FanDuelPlayer.factory(import)

    json_obj.each_pair do |player_id, player_data|
      player = klazz.player(player_data)
      player.player_id = player_id.to_i
      player.import_id = import.id

      if (true == player.ignore?())
        player.ignore = true
      end

      players << player
    end

    FanDuelPlayer.import(players)
  end

  def self.player(player_data)
    status   = player_data[12]
    position = player_data[0]
    note     = player_data[10]
    notes    = []
    
    if ("P" == position)
      status = player_data[9]

      if ((5 == status) || (1 == status))
        notes << "Probable"
      end
    elsif ((nil != note) && (false == note.empty?))
      notes << note
    end

    return self.new({
      :name      => player_data[1],
      :team_id   => player_data[3].to_i,
      :game_id   => player_data[2].to_i,
      :position  => position,
      :average   => player_data[6].to_f,
      :cost      => player_data[5].to_i,
      :status    => status,
      :priority  => player_data[11],
      :notes     => notes,
      :game_data => [],
      :game_log_loaded => false
    })
  end

  def self.load_player_details(params = {})
    import = Import.latest_by_league(params)
    altered_players = []

    if ((nil != import) && (nil != import.fd_game_id))
      klazz = FanDuelPlayer.factory(import)

      klazz.where({:import => import, :game_log_loaded => false}).each do |fd_player|
        if (true == fd_player.game_data.is_a?(Array))
          points = []
          uri  = "#{PLAYER_DETAIL_URL}#{fd_player.player_id}#{PLAYER_DETAIL_URL_EXT}#{import.fd_game_id}"
          cutoff_date = Date.today() - klazz::MAX_DATES
          begin
            page  = Nokogiri::HTML(open("#{uri}"))
            table = page.css('table.game-log')[0].css('tbody')[0]
            
            fd_player.game_data = FanDuelPlayer.parse_player_details(table, klazz::MAX_GAMES, cutoff_date, Date.today)
            fd_player.game_log_loaded = true

            begin
              news_data = FanDuelPlayer.parse_player_news(page.css('div.news-item')[0], Date.today)

              if (news_data[:date] > (Date.today - 5))
                fd_player.notes << news_data[:note]

                if (new_data[:date] == Date.today)
                  if ((true == news_data[:note].include?("is out of the lineup")) ||
                      (true == news_data[:note].include?("not in the lineup")))
                     fd_player.ignore = true
                  end
                end
              end
            rescue Exception => e
              logger.warn "Failed to parse note on player '#{fd_player.name}' in import '#{fd_player.import_id}' - '#{uri}' - #{e}"
            end

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

  def self.parse_player_news(div, today)
    news_data = {}

    timestamp_elem = div.css('h2')[0]
    time_str = "?"
    date_str = timestamp_elem.css('b').text().strip()
    date_str = date_str[0..-3]
    news_data[:date] = Date.strptime("#{date_str},#{today.year}", "%B %d,%Y")

    timestamp_elem.children.each do |child|
      if (true == child.text?)
        time_str = "#{child.text().strip()}"
      end
    end

    div.css('p').each do |p_element|
      if (true == p_element.css('b')[0].text().strip().upcase.include?("UPDATE"))
        p_element.children.each do |child|
          if (true == child.text?)
            news_data[:note] = "#{news_data[:date].strftime("%m/%d")} #{time_str} #{child.text().strip()}"
          end
        end
      end
    end

    return news_data
  end

  def self.parse_player_details(table, max, cutoff_date, today)
    game_data = []

    table.css('tr').each_with_index do |tr, i|
      if (i < max)
        tds = tr.css('td')
        data = FanDuelPlayer.parse_player_detail(tds, cutoff_date, today)

        if (nil != data)
          game_data << data
        end
      else
        break
      end
    end

    return game_data
  end

  def self.parse_player_detail(tds, cutoff_date, today)
    single_game_data = {}

    date = Date.strptime("#{tds[0].text()}/#{today.year}", DATE_FORMAT)

    if (date > today)
      date = date - 365
    end

    if (date > cutoff_date)
      single_game_data[:date]    = date
      single_game_data[:fpoints] = tds[-1].text().to_f.round(2)
      single_game_data[:minutes] = tds[2].text().to_i
    end

    if ((false == single_game_data.empty?()) && ((0 != single_game_data[:fpoints]) || (0 != single_game_data[:minutes])))
      return single_game_data
    else
      return nil
    end
  end

  def self.sort(players, sort_column, ascending = nil)
    sorted_players = players.sort_by do |p|
      if ((0 != p.send(sort_column)) && (true == p.send(sort_column).is_a?(Numeric)))
        p.value = p.cost/p.send(sort_column)
      elsif ((0 != p.avg) && (false == p.send(sort_column).is_a?(Numeric)))
        p.value = p.cost/p.avg
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
    if ("NFL" == params[:league])
      return NflPlayer.get_players(params)
    elsif (nil != params[:league])
      return FanDuelPlayer.get_players(params)
    end
  end

  def self.get_players(params = {})
    import = Import.latest_by_league(params[:league])

    if (nil == import)
      return []
    end

    klazz = FanDuelPlayer.factory(import)
    @@overunders = OverUnder.get_expected_scores(import)

    players = []

    klazz.where({:import => import}).each do |fd_player|
      fd_player.team     = fd_player.team_name

      FanDuelPlayer.process_overunder(fd_player, import)
      FanDuelPlayer.extract_latest_game(fd_player)

      if (false == params.include?(:ignore))
        players << fd_player
      elsif (params[:ignore] == fd_player.ignore)
        players << fd_player
      end
    end

    return players
  end

  def self.process_overunder(fd_player, import)
    if (false == OverUnder::URLS.include?(import.league))
      return
    end

    if (false == @@overunders.include?(fd_player.team_name))
      raise "!ERROR: OverUnder not defined for '#{fd_player.team_name}'."
    else
      fd_player.opp = @@overunders[fd_player.team_name][:opp]

      if (false == @@overunders[fd_player.team_name].include?(:boost))
        @@overunders[fd_player.team_name][:boost] = OverUnder.calculate_boost(@@overunders[fd_player.team_name][:score], @@overunders[:scores])
        @@overunders[fd_player.team_name][:mult]  = OverUnder.calculate_boost_multiplier(@@overunders[fd_player.team_name][:score], @@overunders[:scores])
      end

      if (false == @@overunders[fd_player.opp].include?(:boost))
        @@overunders[fd_player.opp][:boost] = OverUnder.calculate_boost(@@overunders[fd_player.opp][:score], @@overunders[:scores])
        @@overunders[fd_player.opp][:mult]  = OverUnder.calculate_boost_multiplier(@@overunders[fd_player.opp][:score], @@overunders[:scores])
      end

      if (true == fd_player.defensive?)
        fd_player.exp  = -@@overunders[fd_player.opp][:boost]
        fd_player.expmed = (fd_player.med * (1/@@overunders[fd_player.opp][:mult])).round(1)
        fd_player.expavg = (fd_player.avg * (1/@@overunders[fd_player.opp][:mult])).round(1)
        fd_player.expmean = (fd_player.mean * (1/@@overunders[fd_player.opp][:mult])).round(1)
      else
        fd_player.exp  = @@overunders[fd_player.team_name][:boost]
        fd_player.expmed = (fd_player.med * @@overunders[fd_player.team_name][:mult]).round(1)
        fd_player.expavg = (fd_player.avg * @@overunders[fd_player.team_name][:mult]).round(1)
        fd_player.expmean = (fd_player.mean * @@overunders[fd_player.team_name][:mult]).round(1)
      end
    end
  end

  def defensive?
    return false
  end

  def self.extract_latest_game(fd_player)
    if (nil != fd_player.last_game_date)
      if ((false == @@most_recent_game.include?(fd_player.team)) ||  (@@most_recent_game[fd_player.team] < fd_player.last_game_date))
        @@most_recent_game[fd_player.team] = fd_player.last_game_date
      end 
    end

    return @@most_recent_game
  end

  def to_s
    return "#{self.name}"
  end
end
