class Roster < ActiveRecord::Base
  class RosterBudgetException < Exception
  end

  serialize :players, JSON

  DEBUG_SAMPLE_SIZE = 5
  MAX_ROSTER_SIZE = 9
  MAX_BUDGET      = 60000

  def initialize(attributes=nil)
    attr_with_defaults = {:cost => 0, :average => 0, :dvoa => 0, :players => []}.merge(attributes)
    super(attr_with_defaults)
  end

  def copy
    attrs = {}

    self.attributes.each_pair do |k,v|
      if (true == v.is_a?(Array))
        attrs[k] = v.dup
      else
        attrs[k] = v
      end
    end

    return Roster.new(attrs)
  end

  def add(players)
    players.each do |player|
      if (MAX_BUDGET < (self.cost + player[:cost]))
        raise RosterBudgetException.new("!ERROR: Over budget. '#{self}' + '#{player}'")
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

  def players_str
    pstr = ""

    self.players.each do |p|
      pstr << "#{p['name'] || p[:name]}-"
    end

    return pstr.chop
  end

  def to_s
    return "#{self.cost}:#{self.average}:#{self.players_str()}"
  end

  def self.analyze(debug = false)
    week      = WeekDatum.get_week()
    rb_max_avg  = 0
    rb_min_cost = 10000
    skipped     = 0
    positions = ["QB", "TE", "K", "D", "RB", "RB", "WR", "WR", "WR"]
    players   = {}
    completed = []
    rb_combos  = []
    wr_combos  = []
    possibilities = []
    completed_min  = 0
    completed_init = false

    FanDuelPlayer.player_data.each do |player|
      players[player[:position]] ||= []
      players[player[:position]] << player

      if ("RB" == player[:position])
        if (rb_max_avg < player[:avg])
          rb_max_avg  = player[:avg]
        end

        if (rb_min_cost > player[:cost])
          rb_min_cost = player[:cost]
        end
      end
    end

    if (true == debug)
      smaller_players = {}

      players.each_pair do |k,v|
        smaller_players[k] = players[k].sample(DEBUG_SAMPLE_SIZE)
      end

      players = smaller_players
    end

    wr_combos = players["WR"].combination(3).to_a
    rb_combos = players["RB"].combination(2).to_a

    players["QB"].each do |qb|
      players["TE"].each do |te|
        players["K"].each do |k|
          players["D"].each do |d|
            r = Roster.new({:week => week}).add([qb,te,k,d])
            possibilities << r
          end
        end
      end
    end

    puts "#{possibilities.size}"
    puts "#{wr_combos.size}"
    puts "#{rb_combos.size}"
    puts "#{rb_min_cost}:#{rb_max_avg}"

    possibilities.each_with_index do |roster,i|
      if (0 == (i % 100))
        puts "Round: #{i}"
      end

      wr_combos.each do |wrs|
        wr_added_roster    = roster.copy
        wr_added_roster.add(wrs)
        max_avg_iteration  = wr_added_roster.average + rb_max_avg + rb_max_avg
        min_cost_iteration = wr_added_roster.cost + rb_min_cost + rb_min_cost

        if ((max_avg_iteration > completed_min) && (Roster::MAX_BUDGET >= min_cost_iteration))
          rb_combos.each do |rbs|
            begin
              full_roster = wr_added_roster.copy.add(rbs)

              if (false == completed_init)
                completed << full_roster

                if (10 <= completed.size)
                  completed.sort_by! {|r| -r.average}
                  completed_min  = completed[-1].average
                  completed_init = true
                end
              elsif (full_roster.average > completed_min)
                completed.pop
                completed << full_roster
                completed.sort_by! {|r| -r.average}
                completed_min  = completed[-1].average
              end
            rescue RosterBudgetException => e
            end
          end
        else
          skipped += rb_combos.size
        end
      end
    end

    puts "Skipped: #{skipped}."

    if (false == debug)
      Roster.import(completed)
    else
      completed.each do |best_roster|
        puts "#{best_roster}"
      end
    end
  end
end
