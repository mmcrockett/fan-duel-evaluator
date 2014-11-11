require 'open-uri'

class OverUnder < ActiveRecord::Base
  belongs_to :import

  TRANSLATIONS = {
    "NFL" => {
      "GBP" => "GB",
      "SFO" => "SF",
      "NOS" => "NO",
      "KAN" => "KC",
      "TAM" => "TB",
    },
    "NHL" => {
      "LAK" => "LA",
      "TBL" => "TB",
      "Winnipeg" => "WPG",
      "SJS" => "SJ",
      "NAS" => "NSH",
      "NJD" => "NJ",
      "CAL" => "CGY",
      "ANA" => "ANH",
      "Arizona" => "ARI",
      "CLB" => "CLS",
    },
    "NBA" => {
      "SAN" => "SA",
      "NYN" => "NY",
      "NOP" => "NO",
      "GOL" => "GS",
    }
  }

  URLS = {
    "NFL" => "http://m.vegasinsider.com/thisweek/3/NFL",
    "NBA" => "http://m.vegasinsider.com/today/3/NBA",
    "NHL" => "http://m.vegasinsider.com/today/3/NHL"
  }

  def self.translate(league, name)
    if ((true == TRANSLATIONS.include?(league)) && (true == TRANSLATIONS[league].include?(name)))
      return TRANSLATIONS[league][name]
    else
      return name
    end
  end

  def self.load(import)
    page = Nokogiri::HTML(open(URLS[import.league]))
    games = {}
    page.css('[data-game-id]').each do |game|
      game_id = game['data-game-id']

      if ("NFL" == import.league)
        team = game.css('span.team-abbr').text()
      else
        team = game.css('span.column-team').text().split(" ")[1]
      end

      team = OverUnder.translate(import.league, team)

      spread  = game.css('span.column-current').text().split(" ")[0].to_f

      games[game_id] ||= {:overunder => 0, :home_spread => 0}

      if (nil != game['data-away-team'])
        games[game_id][:visitor] = team
      else
        games[game_id][:home] = team
      end

      if (0 < spread)
        games[game_id][:overunder] = spread.to_f
      elsif (nil != game['data-away-team'])
        games[game_id][:home_spread] = -spread
      else
        games[game_id][:home_spread] = spread
      end
    end

    games.each_value do |game|
      OverUnder.create(game.merge({:import_id => import.id}))
    end
  end

  def self.calculate_boost(expected_team_score, scores)
    if (0 == expected_team_score)
      return 0
    else
      return (((expected_team_score - scores.mean)/scores.mean)*100).round()
    end
  end
end
