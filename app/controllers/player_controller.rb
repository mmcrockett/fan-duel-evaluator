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
    @expected_scores = []
    scores = nil
    overunders = OverUnder.get_expected_scores(Import.latest_by_league(params))

    overunders.each_pair do |key, value|
      if (true == value.include?(:score))
        value[:exp_score] = value[:score].round(1)
        value[:exp_opp_score] = overunders[value[:opp]][:score].round(1)
        value[:diff] = value[:exp_score] - value[:exp_opp_score]
        value[:team] = key
        value[:mult] = OverUnder.calculate_boost_multiplier(value[:score], scores)
        @expected_scores << value
      else
        scores = value
      end
    end
  end
end
