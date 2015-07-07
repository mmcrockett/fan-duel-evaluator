require 'player_finder'

class Roster < ActiveRecord::Base
  belongs_to :import
  serialize :player_ids, JSON
  attr_accessor :players

  def self.analyze(league, unique = false)
    puts "Start Time: #{Time.now}"
    start_time = Time.now
    players    = FanDuelPlayer.player_data({:league => league, :ignore => false})
    import_id  = players.first.import_id
    positions  = players.first.class::POSITIONS
    budget     = players.first.class::BUDGET

    best_rosters = Roster.get_best_rosters(players, positions, budget, players.first.class::ANALYZE_COLUMNS, unique)

    best_rosters.each_pair do |name, roster|
      if (true == roster.is_a?(SimpleRoster))
        Roster.create({:import_id => import_id, :notes => "#{name}", :player_ids => roster.player_ids})
      else
        puts "!ERROR: Not a 'SimpleRoster' type - '#{roster.class}'."
      end
    end

    puts "Exec Time: #{Time.now - start_time}"
  end

  def self.get_best_rosters(players, positions, budget, columns, unique = false)
    strategies = [:heavy, :bestbalanced, :value]
    position_permutations = positions.permutation(positions.size).to_a

    best_rosters = {}
    return_rosters = {}

    columns.each do |sort_column|
      #best_rosters[sort_column] ||= {}
      sorted_players = FanDuelPlayer.sort(players, sort_column)
      player_finder  = PlayerFinder.new(sorted_players)
      post_optimize  = true

      position_permutations.each do |position_order|
        rosters = {}
        strategies.each do |strategy|
          key   = "#{strategy}"
          rosters[key] = SimpleRoster.new(budget, positions.size, sort_column)

          position_order.each_with_index do |position, i|
            type     = nil
            options  = {:exclude => rosters[key].players}

            begin
              if (:bestbalanced == strategy)
                type = :best
                options[:max_cost] = rosters[key].remaining_avg_budget*1.2
              elsif (:valuebalanced == strategy)
                type = :value
                options[:max_cost] = rosters[key].remaining_avg_budget*1.2
              elsif (true == Roster.find_best?(strategy, i))
                type = :best
              else
                type = :value

                if (:value != strategy)
                  options[:max_cost] = rosters[key].remaining_avg_budget
                end
              end

              if (i == (positions.size - 1))
                options[:max_cost] = rosters[key].remaining_budget
              end

              if (:value == type)
                rosters[key] << player_finder.find_value(position, options)
              elsif (:best == type)
                rosters[key] << player_finder.find_best(position, options)
              end
            rescue PlayerFinderValidPlayerNotFoundException, SimpleRosterBudgetException
            end
          end

          rosters.each_value do |roster|
            best_rosters[sort_column] = Roster.best(best_rosters[sort_column], roster)
            #best_rosters[sort_column][key] = Roster.best(best_rosters[sort_column][key], roster)
          end
        end
      end

      #best_rosters[sort_column].keys.each do |key|
        post_optimize = true
        #while ((true == post_optimize) && (nil != best_rosters[sort_column][key]))
        while ((true == post_optimize) && (nil != best_rosters[sort_column]))
          #new_best = Roster.post_optimize(best_rosters[sort_column][key], player_finder, sort_column)
          new_best = Roster.post_optimize(best_rosters[sort_column], player_finder, sort_column)

          if (new_best == best_rosters[sort_column])
            post_optimize = false
          else
            best_rosters[sort_column] = new_best
          end
        end
      #end

      best_rosters.each_pair do |scolumn, rosters|
        return_rosters[scolumn] = rosters
        #rosters.each_pair do |strategy, roster|
          #return_rosters["#{scolumn}_#{strategy}"] = roster
        #end
      end

      if (true == unique)
        players = players - return_rosters[sort_column].players
      end
    end

    return return_rosters
  end

  def self.best(roster0, roster1)
    if ((nil == roster0) && (nil == roster1))
      return nil
    elsif (nil == roster0)
      if (true == roster1.complete?())
        return roster1
      else
        return nil
      end
    elsif (nil == roster1)
      if (true == roster0.complete?())
        return roster0
      else
        return nil
      end
    elsif ((false == roster0.complete?()) && (false == roster1.complete?()))
      return nil
    elsif ((true == roster0.complete?()) && (false == roster1.complete?()))
      return roster0
    elsif ((true == roster1.complete?()) && (false == roster0.complete?()))
      return roster1
    elsif (roster0.points > roster1.points)
      return roster0
    else
      return roster1
    end
  end

  def self.post_optimize(best_roster, player_finder, sort_column)
    new_best = nil
    rbudget  = best_roster.remaining_budget
    rplayers = best_roster.players

    rplayers.each do |p|
      begin
        better_player = player_finder.find_best(p.pos, {:max_cost => rbudget + p.cost, :exclude => rplayers})

        if (better_player.send(sort_column) > p.send(sort_column))
          new_roster = best_roster.dup
          new_roster.delete(p)
          new_roster << better_player
          new_best = Roster.best(new_best, new_roster)
        end
      rescue PlayerFinderValidPlayerNotFoundException => e
      end
    end

    return Roster.best(new_best, best_roster)
  end

  def self.find_best?(strategy, i)
    if ((:xheavy == strategy) && (i < 3))
      return true
    elsif ((:heavy == strategy) && (i < 2))
      return true
    end

    return false
  end

  def players
    return @players || []
  end
end
