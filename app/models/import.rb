require 'open-uri'

class Import < ActiveRecord::Base
  has_many :fan_duel_players
  has_many :overunders

  serialize :fd_team_data, JSON

  PLAYER_IMPORT_URL = "https://api.fanduel.com/fixture-lists/"

  def self.parse(uri)
    data = {
      :fd_team_data => {},
      :players => [],
      :fd_contest_id => nil,
      :league => nil
    }
    authorization = nil

    open("#{uri}").each do |line|
      if (nil == authorization)
        authorization = Import.parse_authorization(line)
      else
        break
      end
    end

    if (nil != authorization)
      uri.split("/").each do |v|
        if ("#{v.to_i}" == "#{v}")
          data[:fd_contest_id] = v
        end
      end

      alldata = JSON.parse(open("#{PLAYER_IMPORT_URL}/#{data[:fd_contest_id]}/players", {"Authorization" => "Basic #{authorization}"}).read())

      alldata["teams"].each do |team|
        data[:fd_team_data][team["code"].upcase] = team["id"]
      end

      data[:players] = alldata["players"]
      data[:league]  = alldata["fixtures"][0]["sport"]
    end

    return data
  end

  def self.parse_authorization(line)
    if (true == line.include?("apiClientId"))
      return line.split(":")[1].strip.delete(",")
    else
      return nil
    end
  end

  def self.latest_by_league(params)
    if (true == params.is_a?(String))
      return Import.where({:league => params}).last
    elsif (true == params.is_a?(Hash))
      return Import.where({:league => params[:league]}).last
    end
  end
end
