require 'open-uri'

class PlayerController < ApplicationController
  def index
    @players = []
    possible_players = FanDuelPlayer.player_data(params)

    if (nil != possible_players)
      possible_players.each do |player|
        if ((false != player.starting?) && (false == player.ignore))
          @players << player
        end
      end
    else
      @players = nil
    end
  end

  def analysis
    if (nil != params[:league])
      @rosters = Roster.where({:import => Import.latest_by_league(params), :ignore => false})

      if (nil != @rosters)
        players = FanDuelPlayer.player_data(params)
      
        @rosters.each do |roster|
          roster.players = players.select {|p| roster.player_ids.include?(p.id) }
        end
      end
    end
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

  def details
    FanDuelPlayer.load_player_details(params)

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def overunder
    @over_unders = OverUnderSet.new(Import.latest_by_league(params)).to_a
  end
end
