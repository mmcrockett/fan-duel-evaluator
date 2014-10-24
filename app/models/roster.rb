class Roster
  attr_reader :budget, :roster

  MAX_ROSTER_SIZE = 9
  MAX_BUDGET      = 60000

  def initialize(players = nil)
    @budget = MAX_BUDGET
    @roster = []

    if ((nil != players) && (true == players.is_a?(Array)))
      players.each do |player|
        self.add(player)
      end
    end
  end

  def add(player)
    if (0 > (@budget - player[:cost]))
      raise "!ERROR: Over budget."
    end

    if (MAX_ROSTER_SIZE < (@roster.size + 1))
      raise "!ERROR: Too many players."
    end

    @budget -= player[:cost]
    @roster << player
  end

  def avg
    positions_remaining = MAX_ROSTER_SIZE - @roster.size

    if (0 == positions_remaining)
      return @budget
    else
      return (@budget/positions_remaining).to_i
    end
  end
end
