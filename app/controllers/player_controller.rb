require 'open-uri'

class PlayerController < ApplicationController
  def index
  end

  def analysis
    players   = {}
    completed = []
    positions = ["K", "D", "QB", "RB", "RB", "WR", "WR", "WR", "TE"]
    possibilities = []

    FanDuelPlayer.player_data.each do |player|
      players[player[:position]] ||= []
      players[player[:position]] << player
    end

    players.each_value do |v|
      v.sort_by! {|h| h[:avg]}
      v.reverse!
    end

    positions.combination(3).to_a.each do |position_combo|
      name = "#{position_combo * '-'}"

      if (false == completed.include?(name))
        completed << name
        top_overloaded = Roster.new("#{name}-overloaded")
        top_heavy      = Roster.new("#{name}-topheavy")
        average        = Roster.new("#{name}-average")

        position_combo.each do |position|
          top_overloaded << players[position].best(11000, top_overloaded.roster)
          top_heavy      << players[position].best(top_heavy.average_budget * 1.4, top_heavy.roster)
          average        << players[position].best(average.average_budget, average.roster)
        end

        (positions - position_combo).each do |position|
          top_overloaded << players[position].best(top_overloaded.average_budget, top_overloaded.roster)
          top_heavy      << players[position].best(top_heavy.average_budget, top_heavy.roster)
          average        << players[position].best(average.average_budget, average.roster)
        end

        possibilities << top_overloaded
        possibilities << top_heavy
        possibilities << average
      end
    end

    possibilities.sort_by! {|roster| roster.pts}
    possibilities.reverse!

    @analysis_data = possibilities
  end
end
