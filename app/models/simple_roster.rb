class SimpleRoster
  attr_reader :cost, :average, :dvoa, :players
  attr_writer :cost, :average, :dvoa, :players

  MAX_ROSTER_SIZE = 9
  MAX_BUDGET      = 60000

  def initialize
    @average = 0
    @dvoa    = 0
    @cost    = 0
    @players = []
  end

  def add(players)
    players.each do |player|
      if (MAX_BUDGET < (self.cost + player[:cost]))
        raise "!ERROR: Over budget. '#{self}' + '#{player}'"
      end

      if (MAX_ROSTER_SIZE < (self.players.size + 1))
        raise "!ERROR: Too many players. '#{self}' + '#{player}'"
      end

      self.cost    += player[:cost]
      self.average += player[:avg]
      self.dvoa    += player[:dvoa]
      self.players << player
    end

    return self
  end
end
