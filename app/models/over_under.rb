require 'open-uri'

class OverUnder < ActiveRecord::Base
  belongs_to :import

  ONE_HALF_SYMBOL = 189.chr("UTF-8")

  TRANSLATIONS = {
    "NFL" => {
      "GBP" => "GB",
      "SFO" => "SF",
      "NOS" => "NO",
      "KAN" => "KC",
      "TAM" => "TB",
      "NEP" => "NE",
      "SDC" => "SD",
      "Philadelphia".upcase => "PHI",
      "Chicago".upcase => "CHI",
      "L.A. Chargers".upcase => "LAC",
      "Baltimore".upcase => "BAL",
      "Seattle".upcase => "SEA",
      "Dallas".upcase => "DAL",
      "Indianapolis".upcase => "IND",
      "Houston".upcase => "HOU"
    },
    "NHL" => {
      "LAK" => "LA",
      "TBL" => "TB",
      "WINNIPEG" => "WPG",
      "SJS" => "SJ",
      "NAS" => "NSH",
      "NJD" => "NJ",
      "CAL" => "CGY",
      "ANA" => "ANH",
      "ARIZONA" => "ARI",
      "CLB" => "CLS",
    },
    "NBA" => {
      "SAN" => "SAS",
      "NYN" => "NYK",
      "NOP" => "NOP",
      "GOL" => "GSW",
      "LAK" => "LAL",
    },
    "MLB" => {
      "SFO" => "SFG",
      "CUB" => "CHC",
      "SDG" => "SDP",
    },
    "CBB" => {
      "MISSISSIPPI ST" => "MISST",
      "FLORIDA STATE" => "FLAST",
      "CALIFORNIA" => "CAL" ,
      "WASHINGTON" => "WASH",
      "COLORADO" => "CLRDO",
      "IOWA STATE" => "IOWST",
      "SOUTH CAROLINA" => "SOCAR",
      "MEMPHIS" => "MEMPH",
      "TULANE" => "TLANE",
      "SOUTH FLORIDA" => "SOFLA",
      "EAST CAROLINA" => "ECAR",
      "RUTGERS" => "RUTG",
      "PENN STATE" => "PENST",
      "OREGON" => "ORGN",
      "OREGON STATE" => "ORGST",
      "CLEMSON" => "CLEMS",
      "NORTH CAROLINA" => "UNC",
      "NOTRE DAME" => "NDAME",
      "TEXAS TECH" => "TXTCH",
      "WEST VIRGINIA" => "WSTVA",
      "MICHIGAN STATE" => "MCHST",
      "INDIANA U" => "INDNA",
      "TEXAS" => "TEX",
      "OKLAHOMA" => "OKLA",
      "NEBRASKA" => "NEB",
    }
  }

  URLS = {
    "NFL" => "http://www.vegasinsider.com/nfl/odds/las-vegas/",
    #"NBA" => "http://m.vegasinsider.com/today/3/NBA",
    "NHL" => "http://m.vegasinsider.com/today/3/NHL",
    "MLB" => "http://m.vegasinsider.com/today/3/MLB",
    "CBB" => "http://m.vegasinsider.com/today/3/BKC"
  }

  def self.translate(league, name)
    name.upcase!
    if ((true == TRANSLATIONS.include?(league)) && (true == TRANSLATIONS[league].include?(name)))
      return TRANSLATIONS[league][name]
    else
      return name
    end
  end

  def self.parse_spread(spread_text)
    spread = nil

    if (nil == spread_text)
      spread = 0.0
    else
      spread_text.gsub!(ONE_HALF_SYMBOL, ".5")

      if (true == spread_text.include?('o'))
        (spread,moneyline) = spread_text.split('o')
        spread = spread.to_f * 2 * (1 - OverUnder.moneyline_to_decimal(-(100+moneyline.to_i)))
      elsif (true == spread_text.include?('u'))
        (spread,moneyline) = spread_text.split('u')
        spread = spread.to_f * 2 * OverUnder.moneyline_to_decimal(-(100+moneyline.to_i))
      else
        spread = spread_text.to_f
      end
    end

    return spread.round(1)
  end

  def self.moneyline_to_decimal(moneyline)
    if (0 < moneyline)
      return (100.to_f/(100+moneyline))
    else
      return (-moneyline.to_f/(100-moneyline))
    end
  end

  def self.load(import)
    if (false == URLS.include?(import.league))
      return
    end

    page = Nokogiri::HTML(open(URLS[import.league]))

    games = []

    page.css('.frodds-data-tbl tr').each do |game|
      parts    = game.css('td')

      if (1 < parts.size)
        game = {
          overunder: 0,
          home_spread: 0,
          home: '',
          visitor: ''
        }

        td_teams = parts.first.css('a')
        td_line  = parts[2]

        away_team = td_teams.first.text()
        home_team = td_teams.last.text()

        game[:visitor] = OverUnder.translate(import.league, away_team)
        game[:home] = OverUnder.translate(import.league, home_team)

        [td_line.css('a').first.children()[2].text(), td_line.css('a').first.children()[4].text()].each_with_index do |v, i|
          spread = OverUnder.parse_spread(v)

          if (0 < spread)
            game[:overunder] = spread.to_f
          elsif (0 == i)
            game[:home_spread] = -spread
          else
            game[:home_spread] = spread
          end
        end

        games << game
      end
    end

    games.each do |game|
      OverUnder.create(game.merge(import_id: import.id))
    end
  end
end
