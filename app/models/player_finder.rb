class PlayerFinderValidPlayerNotFoundException < Exception
end

class PlayerFinder
  attr_reader :cost, :average, :players, :budget
  attr_writer :cost, :average, :players

  def initialize(sorted_players)
    @by_cost  = {}
    @by_value = {}
    @players  = {}

    sorted_players.each do |player|
      @by_cost[player.position]  ||= {}

      if (false == @by_cost[player.position].include?(player.cost))
        add_player(player)
      elsif (@by_cost[player.position][player.cost].size < player.class::POSITIONS.count(player.position))
        add_player(player)
      end
    end
  end

  def find_best(position, options = {})
    players = @players[position]

    players.each do |player|
      if ((position == player.position) && (true == valid?(player, options)))
        return player
      end
    end

    raise_exception(position, options)
  end

  def find_value(position, options = {})
    if (false == @by_value.include?(:sorted))
      sorted_by_value = {}

      @by_value.each_pair do |k,v|
        sorted_by_value[k] = v.sort_by{|p| p.value}
      end

      @by_value = sorted_by_value
      @by_value[:sorted] = true
    end

    @by_value[position].each do |player|
      if (true == valid?(player, options))
        return player
      end
    end

    raise_exception(position, options)
  end

  private
  def add_player(player)
    @by_value[player.position] ||= []
    @players[player.position]  ||= []

    if (false == @by_cost[player.position][player.cost].is_a?(Array))
      @by_cost[player.position][player.cost]  = [player]
    else
      @by_cost[player.position][player.cost]  << player
    end

    @by_value[player.position] << player

    @players[player.position] << player
  end

  def valid?(player, options)
    if (false == options.include?(:max_cost))
      options[:max_cost] = @players.values.first.first.class::BUDGET
    end

    if (false == options.include?(:exclude))
      options[:exclude] = []
    end

    return ((options[:max_cost] >= player.cost) && (false == options[:exclude].include?(player)))
  end

  def raise_exception(position, options)
    err_str  = "!ERROR: Unable to find player for '#{position}' with params "
    err_str += "'#{options[:max_cost]}'"
    options[:exclude].each do |p|
      err_str += " '#{p.position}:#{p.name}:#{p.cost}' "
    end
    raise PlayerFinderValidPlayerNotFoundException.new(err_str)
  end
end
