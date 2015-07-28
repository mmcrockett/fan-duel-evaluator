class ImportsController < ApplicationController
  def index
    @import = Import.latest_by_league(params)
  end

  def create
    data = Import.parse(params[:uri])
    players = data.delete(:players)

    @import = Import.create(data)

    FanDuelPlayer.parse(players, @import)

    if ("NFL" == @import.league)
      Yahoo.load(@import.id)
      Dvoa.load(@import.id)
    elsif ("NHL" == @import.league)
      NhlStandings.load(@import.id)
    end

    OverUnder.load(@import)

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
