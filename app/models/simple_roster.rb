class SimpleRosterNotFoundException < Exception
end

class SimpleRosterBudgetException < Exception
end

class SimpleRosterSizeException < Exception
end

class SimpleRosterDuplicateException < Exception
end

class SimpleRoster
  attr_reader :cost, :points, :players, :budget, :pcolumn
  attr_writer :cost, :points, :players

  def initialize(budget, max_roster_size, pcolumn = :avg)
    @max_roster_size = max_roster_size
    @budget  = budget
    @points  = 0
    @cost    = 0
    @pcolumn = pcolumn
    @players = []
  end

  def remaining_budget
    return (@budget - @cost)
  end

  def remaining_avg_budget
    if (@max_roster_size != @players.size)
      return (remaining_budget/(@max_roster_size - @players.size)).to_i
    else
      return 0
    end
  end

  def dup
    my_clone = SimpleRoster.new(self.budget) 

    my_clone.cost    = self.cost
    my_clone.points  = self.points
    my_clone.players = self.players.dup

    return my_clone
  end

  def <<(players)
    if (false == players.is_a?(Array))
      players = [players]
    end

    players.each do |player|
      if (@budget < (@cost + player.cost))
        raise SimpleRosterBudgetException.new("!ERROR: Over budget. '#{self}' + '#{player}:$#{player.cost}'")
      end

      if (@max_roster_size < (@players.size + 1))
        raise SimpleRosterSizeException.new("!ERROR: Too many players. '#{self}' + '#{player}'")
      end

      if (true == @players.include?(player))
        raise SimpleRosterDuplicateException.new("!ERROR: Same player added. '#{self}' + '#{player}'")
      end

      @cost    += player.cost
      @points  += player.send(@pcolumn)
      @players << player
    end

    return self
  end

  def delete(player)
    if (false == @players.include?(player))
      raise SimpleRosterNotFoundException.new()
    end

    @players.delete(player)
    @cost    -= player.cost
    @points  -= player.send(@pcolumn)

    return self
  end

  def complete?
    return (@max_roster_size == @players.size)
  end

  def player_ids
    ids = []

    @players.each do |p|
      ids << p.id
    end

    return ids
  end

  def to_s
    str = "$#{@cost}:#{@points} #{@pcolumn}"

    @players.each do |p|
      str += "-#{p.name}"
    end

    return str
  end
end
