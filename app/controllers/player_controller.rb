require 'open-uri'

class PlayerController < ApplicationController
  def index
  end

  def analysis
    positions = ["QB", "TE", "K", "D", "RB", "RB", "WR", "WR", "WR"]
    players   = {}
    completed = []
    rb_combos  = []
    wr_combos  = []
    possibilities = []

    FanDuelPlayer.player_data.each do |player|
      players[player[:position]] ||= []
      players[player[:position]] << player
    end

    wr_combos = players["WR"].combination(3).to_a
    rb_combos = players["RB"].combination(2).to_a

    puts "#{wr_combos.size}"
    puts "#{rb_combos.size}"

    players["QB"].each do |qb|
      players["TE"].each do |te|
        players["K"].each do |k|
          players["D"].each do |d|
            possibilities << Roster.new([qb,te,k,d])
          end
        end
      end
    end

    raise "#{possibilities.size}"

    @analysis_data = possibilities
  end

  def ignore
    fd_players = FanDuelPlayer.find(params[:ignore])

    FanDuelPlayer.transaction do 
      fd_players.each do |fd_player|
        fd_player.ignore = true
        fd_player.save
      end
    end
  end
end
