include ActionView::Helpers::NumberHelper

class Roster < ActiveRecord::Base
  serialize :players, JSON

  SAMPLE_SET_SIZE    = {
    "QB" => 2,
    "WR" => 4,
    "RB" => 2,
    "TE" => 2,
    "K"  => 4,
    "D"  => 4,
  }
  SAMPLE_TOP_PERCENT = 0.2
  MAX_NUMBER_ROSTERS = 20

  def players_str
    pstr = ""

    self.players.each do |p|
      cost = p['cost'] || p[:cost]
      name = p['name'] || p[:name]
      pos  = p['position'] || p[:position]
      team = p['team'] || p[:team]
      display_name = "ERROR"

      if ("D" == pos)
        display_name = "#{team[0,3]} D"
      else
        (first_name, last_name) = name.split(" ", 2)
        display_name = "#{first_name[0]}. #{last_name}"
      end
      pstr << "#{display_name} (#{cost})-"
    end

    return pstr.chop
  end

  def to_s
    return "#{self.cost}:#{self.average}:#{self.players_str()}"
  end

  def self.analyze(params = {:debug => false, :k_d_ignore => false})
    start_time = Time.now
    week       = WeekDatum.get_week()
    max_avgs   = {}
    min_costs  = {}
    skipped    = {:L1 => 0, :L2 => 0, :sort_t => 0}
    positions = ["QB", "TE", "K", "D", "RB", "RB", "WR", "WR", "WR"]
    players   = {}
    sampled_players = {}
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

    players.each_pair do |k,v|
      sample_size = SAMPLE_SET_SIZE[k]
      tmp = []
      sampled_players[k] = []
      players[k].sort_by! {|p| -p[:cost]}
      players_count = players[k].size

      players[k].each_with_index do |player, i|
        if (i < (players_count * SAMPLE_TOP_PERCENT))
          sampled_players[k] << player
        elsif (("QB" == player[:position]) && (i > (players_count - sample_size)))
          sampled_players[k] << player
        else
          tmp << player
        end

        if (sample_size < tmp.size)
          sampled_players[k] << tmp.sample
          tmp = []
        end
      end
    end

    players = sampled_players

    wr_combos    = players["WR"].combination(3).to_a
    rb_combos    = players["RB"].combination(2).to_a

    players["QB"].each do |qb|
      players["TE"].each do |te|
        qb_te_combos << [qb,te]
      end
    end

    if (false == params[:k_d_ignore])
      players["K"].each do |k|
        players["D"].each do |d|
          k_d_combos << [k,d]
        end
      end
    else
      kicker = {:cost => min_costs["K"],
                :avg  => 0,
                :dvoa => 0,
                :name => "Team K"
      }
      defense = {:cost => min_costs["D"],
                :avg  => 0,
                :dvoa => 0,
                :name => "Team D"
      }
      k_d_combos << [kicker, defense]
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
    puts "Exec Time: #{Time.now - start_time}"

    puts "Processed: #{number_with_delimiter(total_size)}"
    puts "Skipped 1: #{number_with_delimiter(skipped[:L1])}."
    puts "Skipped 2: #{number_with_delimiter(skipped[:L2])}."

    if (false == params[:debug])
      Roster.import(completed)
    else
      completed[0,10].each do |best_roster|
        puts "#{best_roster}"
      end
    end
  end
end
