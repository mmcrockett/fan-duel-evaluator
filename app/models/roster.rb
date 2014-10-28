class Roster < ActiveRecord::Base
  serialize :players, JSON

  DEBUG_SAMPLE_SIZE = 5

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
            r = SimpleRoster.new.add([qb,te,k,d])
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
        wr_roster          = SimpleRoster.new.add(wrs)
        max_avg_iteration  = wr_roster.average + roster.average + rb_max_avg + rb_max_avg
        min_cost_iteration = wr_roster.cost + roster.cost + rb_min_cost + rb_min_cost

        if ((max_avg_iteration > completed_min) && (SimpleRoster::MAX_BUDGET >= min_cost_iteration))
          rb_combos.each do |rbs|
            rb_roster = SimpleRoster.new.add(rbs)

            if ((SimpleRoster::MAX_BUDGET >= (roster.cost + wr_roster.cost + rb_roster.cost)))
              if ((false == completed_init) || ((roster.average + wr_roster.average + rb_roster.average) > completed_min))
                completed << Roster.new(
                                        {
                                          :week => week,
                                          :average => roster.average + wr_roster.average + rb_roster.average,
                                          :dvoa    => roster.dvoa    + wr_roster.dvoa    + rb_roster.dvoa,
                                          :cost    => roster.cost    + wr_roster.cost    + rb_roster.cost,
                                          :players => roster.players + wr_roster.players + rb_roster.players
                                        }
                                       )

                if (10 < completed.size)
                  completed.sort_by! {|r| -r.average}
                  completed.pop
                  completed_min  = completed[-1].average
                  completed_init = true
                end
              end
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
