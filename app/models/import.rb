class Import < ActiveRecord::Base
  has_many :fan_duel_players
  has_many :overunders

  def self.latest_by_league(params)
    if (true == params.is_a?(String))
      return Import.where({:league => params}).last
    elsif (true == params.is_a?(Hash))
      return Import.where({:league => params[:league]}).last
    end
  end
end
