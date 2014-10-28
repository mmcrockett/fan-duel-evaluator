require 'open-uri'

class PlayerController < ApplicationController
  def index
  end

  def analysis
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
