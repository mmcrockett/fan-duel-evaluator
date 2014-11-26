require 'open-uri'

class PlayerController < ApplicationController
  def index
    @players = FanDuelPlayer.player_data(params)
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

  def import
  end

  def create
    @import = Import.create({:league => params[:league], :fd_game_id => params[:fd_game_id]})

    FanDuelPlayer.parse(params[:data], @import)

    if ("NFL" == @import.league)
      Yahoo.load(@import.id)
      Dvoa.load(@import.id)
    end

    OverUnder.load(@import)

    respond_to do |format|
      format.json { head :no_content }
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
end
