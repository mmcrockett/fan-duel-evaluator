class SimpleRoster
  attr_reader :cost, :average, :players, :budget
  attr_writer :cost, :average, :players

  MAX_ROSTER_SIZE = 9

  def initialize(budget)
    @budget  = budget
    @average = 0
    @cost    = 0
    @players = []
  end

  def add(players)
    players.each do |player|
      if (self.budget (self.cost + player.cost))
        raise "!ERROR: Over budget. '#{self}' + '#{player}'"
      end

      if (MAX_ROSTER_SIZE < (self.players.size + 1))
        raise "!ERROR: Too many players. '#{self}' + '#{player}'"
      end

      self.cost    += player.cost
      self.average += player.average
      self.players << player
    end

    return self
  end
end
