require 'open-uri'

class NhlStandingsException < Exception
end

class NhlStandingsNotInitializedException < Exception
end

class NhlStandings < ActiveRecord::Base
  belongs_to :import

  @@import_id = nil
  @@gfa   = {}
  @@gaa   = {}

  URI = "http://sports.yahoo.com/nhl/standings/"

  TEAM_CONVERSION = {
    "Tampa Bay"    => "TB",
    "Montreal"     => "MON",
    "Detroit"      => "DET",
    "Boston"       => "BOS",
    "Toronto"      => "TOR",
    "Florida"      => "FLA",
    "Ottawa"       => "OTT",
    "Buffalo"      => "BUF",
    "Pittsburgh"   => "PIT",
    "NY Islanders" => "NYI",
    "NY Rangers"   => "NYR",
    "Washington"   => "WAS",
    "New Jersey"   => "NJ",
    "Philadelphia" => "PHI",
    "Carolina"     => "CAR",
    "Columbus"     => "CLS",
    "Nashville"    => "NSH",
    "St. Louis"    => "STL",
    "Chicago"      => "CHI",
    "Winnipeg"     => "WPG",
    "Minnesota"    => "MIN",
    "Dallas"       => "DAL",
    "Colorado"     => "COL",
    "Vancouver"    => "VAN",
    "Anaheim"      => "ANH",
    "Calgary"      => "CGY",
    "Los Angeles"  => "LA",
    "San Jose"     => "SJ",
    "Arizona"      => "ARI",
    "Edmonton"     => "EDM"
  }

  def self.load(import_id)
    page = Nokogiri::HTML(open("#{URI}"))

    page.css('#Main')[0].css('table').each do |standings_table|
      standings_table.css('tbody')[0].css('tr').each do |tr|
        team = tr.css('.team')[0].text().strip()
        gf   = tr.css('.goals-for')[0].text().strip()
        ga   = tr.css('.goals-against')[0].text().strip()
        gp   = tr.css('.games-played')[0].text().strip()

        NhlStandings.new({:team => team, :games => gp, :goals_scored => gf, :goals_allowed => ga, :import_id => import_id}).save
      end
    end
  end

  def self.data(import_id)
    if (@@import_id != import_id)
      NhlStandings.where("import_id = ?", import_id).each do |standing|
        @@gfa[NhlStandings.team_conversion(standing.team)] = standing.goals_scored.to_f/standing.games
        @@gaa[NhlStandings.team_conversion(standing.team)] = standing.goals_allowed.to_f/standing.games
      end

      @@import_id = import_id
    end
  end

  def self.team_conversion(name)
    if (false == TEAM_CONVERSION.include?(name))
      raise NhlStandingsException.new("!ERROR: Don't have a conversion for '#{name}' in '#{TEAM_CONVERSION.keys}'.")
    else
      return TEAM_CONVERSION[name]
    end
  end

  def self.goals_scored_exp(team)
    if (nil == @@import_id)
      raise NhlStandingsNotInitializedException.new("!ERROR: Not initialized.")
    end

    return (NhlStandings.goals_scored_avg(team) - NhlStandings.goals_scored_avg)/Math.sqrt(@@gfa.values.variance)
  end

  def self.goals_allowed_exp(team)
    if (nil == @@import_id)
      raise NhlStandingsNotInitializedException.new("!ERROR: Not initialized.")
    end

    return (NhlStandings.goals_allowed_avg(team) - NhlStandings.goals_allowed_avg)/Math.sqrt(@@gaa.values.variance)
  end

  def self.goals_allowed_avg(team = nil)
    if (nil == @@import_id)
      raise NhlStandingsNotInitializedException.new("!ERROR: Not initialized.")
    end

    if (nil == team)
      return @@gaa.values.mean
    else
      if (false == @@gaa.include?(team))
        raise NhlStandingsException.new("!ERROR: Couldn't find '#{team}' in '#{@@gaa.keys}'.")
      else
        return @@gaa[team]
      end
    end
  end

  def self.goals_scored_avg(team = nil)
    if (nil == @@import_id)
      raise NhlStandingsNotInitializedException.new("!ERROR: Not initialized.")
    end

    if (nil == team)
      return @@gfa.values.mean
    else
      if (false == @@gfa.include?(team))
        raise NhlStandingsException.new("!ERROR: Couldn't find '#{team}' in '#{@@gfa.keys}'.")
      else
        return @@gfa[team]
      end
    end
  end
end
