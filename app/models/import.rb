require 'open-uri'

class Import < ActiveRecord::Base
  has_many :fan_duel_players
  has_many :overunders

  def self.parse(uri)
    fd_game_id = nil
    type  = nil
    data  = nil
    teams = nil

    open("#{uri}").each do |line|
      if (nil == data)
        data = Import.parse_data(line)
      end

      if (nil == type)
        type = Import.parse_type(line)
      end

      if (nil == fd_game_id)
        fd_game_id = Import.parse_fd_game_id(line)
      end

      if (nil == teams)
        teams = Import.parse_teams(line)
      end
    end

    return {:teams => teams, :league => type, :fd_game_id => fd_game_id, :data => data}
  end

  def self.parse_type(line)
    if (true == line.include?("FD.playerpicker.competitionName"))
      value = Import.value(line)

      return value.split("'")[1]
    else
      return nil
    end
  end

  def self.parse_fd_game_id(line)
    if (true == line.include?("FD.playerpicker.gameId"))
      return Import.value(line)
    else
      return nil
    end
  end

  def self.parse_data(line)
    if (true == line.include?("FD.playerpicker.allPlayersFullData"))
      return Import.value(line)
    else
      return nil
    end
  end

  def self.parse_teams(line)
    if (true == line.include?("FD.playerpicker.teamIdToFixtureCompactString"))
      teams = {}

      JSON.parse(Import.value(line)).each_pair do |id, team_str|
        i = team_str.index("<b>") + 3
        j = team_str.index("</b>") - 1

        teams[id] = team_str[i..j]
      end

      return teams
    else
      return nil
    end
  end

  def self.value(kv_pair)
    return kv_pair.split("=")[1].strip.delete(";")
  end

  def self.latest_by_league(params)
    if (true == params.is_a?(String))
      return Import.where({:league => params}).last
    elsif (true == params.is_a?(Hash))
      return Import.where({:league => params[:league]}).last
    end
  end
end
