require 'open-uri'

class PlayerController < ApplicationController
  def index
    if ("NFL" == params[:league])
      @players = NflPlayer.player_data(params)
    else
      @players = FanDuelPlayer.player_data(params)
    end
  end

  def analysis
  end

  def import
  end

  def create
    @import = Import.create({:league => params[:league]})

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
end
