require 'array_mod'
include ActionView::Helpers::NumberHelper

class FanDuelPlayer < ActiveRecord::Base
  include Auditable

  SINGLE = ["QB", "K", "D", "TE"]
  DOUBLE = ["RB"]
  TRIPLE = ["WR"]

  def defense?
    return (self.position == "D")
  end

  def self.parse(data, week)
    audit = self.get_audit({:week => week, :source => "#{self}", :subsource => ""})

    if (0 == audit.status)
      players  = []
      json_obj = JSON.load(data)
      audit.url = "User Input"
      audit.save

      json_obj.each_value do |player_data|
        players << FanDuelPlayer.player(player_data, week)
      end

      FanDuelPlayer.import(players)
      audit.status = 1
      audit.save
      self.set_week_data(week, self)
    end
  end

  def self.player(player_data, week)
    return FanDuelPlayer.new({
      :name     => player_data[1],
      :week     => week,
      :team_id  => player_data[3].to_i,
      :position => player_data[0],
      :average  => player_data[6].to_f,
      :cost     => player_data[5].to_i,
      :status   => player_data[12],
      :note     => player_data[10]
    })
  end

  def self.player_data(params = {})
    players = []
    week = WeekDatum.get_week(params)

    stats  = {}
    averages = {}
    FanDuelPlayer.where({:week => week, :ignore => false}).each do |fd_player|
      last_week_fd_player = FanDuelPlayer.find_by({:week => (week - 1), :name => fd_player.name}) || FanDuelPlayer.new({:cost => 0, :average => 0})
      player = {}
      player[:id]       = fd_player.id
      player[:name]     = fd_player.name
      player[:position] = fd_player.position
      player[:team]     = FfTodayPrediction.translate_team_name(FanDuelPlayer.find_by({:week => week, :position => "D", :team_id => fd_player.team_id}).name)
      player[:opponent] = FfTodayPrediction.find_by({:week => week, :position => fd_player.position, :team => player[:team]}).opponent
      player[:status]   = fd_player.status
      player[:cost]     = fd_player.cost
      player[:pcost]    = last_week_fd_player.cost
      player[:stddevs]  = -10
      player[:avg]      = fd_player.average
      player[:pavg]     = last_week_fd_player.average

      if (true == fd_player.defense?())
        if (0 == player[:avg])
          player[:avg] = Yahoo.find_by({:week => week, :team => player[:team]}).average
        else
          raise "!ERROR: Non-zero defense '#{player[:name]}' average '#{player[:avg]}' - Can't reset."
        end
      end

      averages[player[:position]] ||= []
      averages[player[:position]] << player[:avg]

      player[:dvoa]     = number_with_precision(player[:avg] * Dvoa.adjustment(week, player[:position], player[:opponent]), :precision => 2).to_f
      player[:fftoday]  = number_with_precision(player[:avg] * FfTodayPrediction.adjustment(week, player[:position], player[:team]), :precision => 2).to_f

      players << player
    end

    averages.each_pair do |position, player_averages|
      player_averages.sort!.reverse!
      top_players = nil

      if (FanDuelPlayer::SINGLE.include?(position))
        top_players = player_averages[0,30]
      elsif (FanDuelPlayer::DOUBLE.include?(position))
        top_players = player_averages[0,60]
      elsif (FanDuelPlayer::TRIPLE.include?(position))
        top_players = player_averages[0,90]
      else
        raise "!ERROR: Missing position '#{position}'."
      end

      stats[position] ||= {}
      stats[position][:var]  = top_players.variance
      stats[position][:mean] = top_players.mean
    end

    players.each do |player|
      position = player[:position]
      player[:stddevs] = number_with_precision((player[:avg] - stats[position][:mean])/Math.sqrt(stats[position][:var]), :precision => 2).to_f
      player[:avg]     = player[:avg].to_f
    end

    return players.select {|p| (("D" == p[:position]) || ("K" == p[:position]) || (5 < p[:avg]))}
  end
end
