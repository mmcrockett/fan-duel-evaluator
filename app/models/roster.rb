require 'player_finder'

class Roster < ActiveRecord::Base
  belongs_to :import
  serialize :player_ids, JSON
  attr_accessor :players

  #COLUMNS = [:avg, :max, :min, :mean, :med]
  #COLUMNS = [:max, :min, :med, :expp]
  COLUMNS = [:max]

  def self.analyze(league)
    puts "Start Time: #{Time.now}"
    start_time = Time.now
    players    = FanDuelPlayer.player_data({:league => league})
    import_id  = players.first.import_id
    positions  = players.first.class::POSITIONS
    budget     = players.first.class::BUDGET

    best_rosters = Roster.get_best_rosters(players, positions, budget)

    best_rosters.each_pair do |col, roster|
      Roster.create({:import_id => import_id, :notes => "#{col}", :player_ids => roster.player_ids})
    end

    puts "Exec Time: #{Time.now - start_time}"
  end

  def self.get_best_rosters(players, positions, budget)
    strategies = [:xheavy, :heavy, :valuebalanced, :bestbalanced]
    position_permutations = positions.permutation(positions.size).to_a

    best_rosters = {}

    COLUMNS.each do |sort_column|
      best_rosters[sort_column] = nil
      sorted_players = FanDuelPlayer.sort(players, sort_column)
      player_finder  = PlayerFinder.new(sorted_players)
      #post_optimize  = true
      post_optimize  = false

      position_permutations.each do |position_order|
        rosters = {}
        strategies.each do |strategy|
          key   = "#{strategy}"
          force = false
          rosters[key] = SimpleRoster.new(budget, positions.size, sort_column)
          i = 0

          while (i < position_order.size)
            position = position_order[i]
            begin
              if (true == Roster.find_best?(strategy, i))
                rosters[key] << player_finder.find_best(position, {:exclude => rosters[key].players})
              elsif (true == Roster.find_best_capped?(strategy, i, positions.size))
                rosters[key] << player_finder.find_best(position, {:max_cost => (rosters[key].remaining_avg_budget*1.2).to_i, :exclude => rosters[key].players})
              elsif (i < (positions.size - 1))
                rosters[key] << player_finder.find_value(position, {:max_cost => rosters[key].remaining_avg_budget*1.2, :exclude => rosters[key].players})
              else
                rosters[key] << player_finder.find_best(position, {:max_cost => rosters[key].remaining_budget, :exclude => rosters[key].players})
              end
              i += 1
            rescue PlayerFinderValidPlayerNotFoundException,SimpleRosterBudgetException
              rosters[key].delete(rosters[key].players[-1])
              i -= 1
            end
          end
        end

        rosters.each_value do |roster|
          if (true == roster.complete?)
            if ((nil == best_rosters[sort_column]) || (roster.points > best_rosters[sort_column].points))
              best_rosters[sort_column] = roster
            end
          end
        end
      end

      while (true == post_optimize)
        rbudget = best_rosters[sort_column].remaining_budget
        players = best_rosters[sort_column].players

        players.each_with_index do |best_player, i|
          begin
            possible_better_player = player_finder.find_best(best_player.position, {:max_cost => rbudget + best_player.cost, :exclude => players})

            if (possible_better_player.send(sort_column) > best_player.send(sort_column))
              best_rosters[sort_column].delete(best_player)
              best_rosters[sort_column] << possible_better_player

              break
            end
          rescue PlayerFinderValidPlayerNotFoundException
          end

          if (i == (players.size - 1))
            post_optimize = false
          end
        end
      end
    end

    return best_rosters
  end

  def self.find_best?(strategy, i)
    if ((:xheavy == strategy) && (i < 3))
      return true
    elsif ((:heavy == strategy) && (i < 2))
      return true
    end

    return false
  end

  def self.find_best_capped?(strategy, i, length)
    if ((:rbalanced == strategy) && (i < (length - 1)))
      return true
    end

    return false
  end

  def players
    return @players || []
  end
end
