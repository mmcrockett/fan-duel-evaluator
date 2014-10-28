include ActionView::Helpers::NumberHelper

class Roster < ActiveRecord::Base
  serialize :players, JSON

  DEBUG_SAMPLE_SIZE  = 10
  MAX_NUMBER_ROSTERS = 100

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
    start_time = Time.now
    week       = WeekDatum.get_week()
    max_avgs   = {}
    min_costs  = {}
    skipped    = {:L1 => 0, :L2 => 0}
    positions = ["QB", "TE", "K", "D", "RB", "RB", "WR", "WR", "WR"]
    players   = {}
    completed = []
    rb_combos  = []
    wr_combos  = []
    k_d_combos   = []
    qb_te_combos = []
    completed_min  = 0
    completed_init = false

    FanDuelPlayer.player_data.each do |player|
      pos = player[:position]
      players[pos]   ||= []
      max_avgs[pos]  ||= 0
      min_costs[pos] ||= 10000
      players[pos] << player

      if (max_avgs[pos] < player[:avg])
        max_avgs[pos] = player[:avg]
      end

      if (min_costs[pos] > player[:cost])
        min_costs[pos] = player[:cost]
      end
    end

    if (true == debug)
      smaller_players = {}

      players.each_pair do |k,v|
        smaller_players[k] = players[k].sample(DEBUG_SAMPLE_SIZE)
      end

      players = smaller_players
    end

    wr_combos    = players["WR"].combination(3).to_a
    rb_combos    = players["RB"].combination(2).to_a

    players["QB"].each do |qb|
      players["TE"].each do |te|
        qb_te_combos << [qb,te]
      end
    end

    players["K"].each do |k|
      players["D"].each do |d|
        k_d_combos << [k,d]
      end
    end

    total_size = wr_combos.size * rb_combos.size * k_d_combos.size * qb_te_combos.size
    puts "QB:TE:#{qb_te_combos.size}"
    puts "WR   :#{wr_combos.size}"
    puts "RB   :#{rb_combos.size}"
    puts "K:D  :#{k_d_combos.size}"
    puts "#{max_avgs}:#{min_costs}"
    puts "#{number_with_delimiter(total_size)}"

    l1_saved = k_d_combos.size * qb_te_combos.size
    l2_saved = k_d_combos.size

    wr_combos.each_with_index do |c0,i|
      r0 = SimpleRoster.new.add(c0)
      if (0 == (i % 100))
        if (0 != i)
          print "\r"
        end
        print "#{number_to_percentage((i*100)/wr_combos.size, :precision => 2)}"
      end

      rb_combos.each do |c1|
        r1 = SimpleRoster.new.add(c1)
        max_avg  = r0.average + r1.average + max_avgs["QB"]  + max_avgs["TE"]  + max_avgs["K"]  + max_avgs["D"]
        min_cost = r0.cost    + r1.cost    + min_costs["QB"] + min_costs["TE"] + min_costs["K"] + min_costs["D"]

        if ((max_avg > completed_min) && (SimpleRoster::MAX_BUDGET >= min_cost))
          qb_te_combos.each do |c2|
            r2 = SimpleRoster.new.add(c2)
            max_avg  = r0.average + r1.average + r2.average + max_avgs["K"]  + max_avgs["D"]
            min_cost = r0.cost    + r1.cost    + r2.cost    + min_costs["K"] + min_costs["D"]

            if ((max_avg  > completed_min) && (SimpleRoster::MAX_BUDGET >= min_cost))
              k_d_combos.each do |c3|
                r3 = SimpleRoster.new.add(c3)
                max_avg  = r0.average + r1.average + r2.average + r3.average
                min_cost = r0.cost    + r1.cost    + r2.cost    + r3.cost

                if ((SimpleRoster::MAX_BUDGET >= min_cost))
                  if ((false == completed_init) || (max_avg > completed_min))
                    completed << Roster.new(
                                            {
                                              :week => week,
                                              :average => max_avg,
                                              :dvoa    => r0.dvoa + r1.dvoa + r2.dvoa + r3.dvoa,
                                              :cost    => min_cost,
                                              :players => r0.players + r1.players + r2.players + r3.players
                                            }
                                          )

                    if (MAX_NUMBER_ROSTERS < completed.size)
                      completed.sort_by! {|r| -r.average}
                      completed.pop
                      completed_min  = completed[-1].average
                      completed_init = true
                    end
                  end
                end
              end
            else
              skipped[:L2]  += l2_saved
            end
          end
        else
          skipped[:L1]  += l1_saved
        end
      end
    end

    puts ""
    puts "#{Time.now - start_time}"

    puts "Processed: #{number_with_delimiter(total_size)}"
    puts "Skipped 1: #{number_with_delimiter(skipped[:L1])}."
    puts "Skipped 2: #{number_with_delimiter(skipped[:L2])}."

    if (false == debug)
      Roster.import(completed)
    else
      completed[0,10].each do |best_roster|
        puts "#{best_roster}"
      end
    end
  end
end
