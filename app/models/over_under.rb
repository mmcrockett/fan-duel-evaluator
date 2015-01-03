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
      "NEP" => "NE",
      "SDC" => "SD",
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
      "LAK" => "LAL",
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
    }
  }

  URLS = {
    "NFL" => "http://m.vegasinsider.com/thisweek/3/NFL",
    "NBA" => "http://m.vegasinsider.com/today/3/NBA",
    "NHL" => "http://m.vegasinsider.com/today/3/NHL",
    "CBB" => "http://m.vegasinsider.com/today/3/BKC"
  }

  def self.translate(league, name)
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
      if (true == spread_text.include?('o'))
        (spread,moneyline) = spread_text.split('o')
        spread = spread.to_f * 2 * OverUnder.moneyline_to_decimal(-(100+moneyline.to_i))
      elsif (true == spread_text.include?('u'))
        (spread,moneyline) = spread_text.split('u')
        spread = spread.to_f * 2 * (1 - OverUnder.moneyline_to_decimal(-(100+moneyline.to_i)))
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
    games = {}
    page.css('[data-game-id]').each do |game|
      game_id = game['data-game-id']

      if ("NFL" == import.league)
        team = game.css('span.team-abbr').text()
      else
        game.css('span.column-team').text().split(" ").each_with_index do |name, i|
          if (1 == i)
            team = "#{name}"
          elsif (0 != i)
            team += " #{name}"
          end
        end
      end

      team = OverUnder.translate(import.league, team)

      spread = OverUnder.parse_spread(game.css('span.column-current').text().split(" ")[0])

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

  def self.calculate_boost_multiplier(expected_team_score, scores)
    return (1 + self.multiplier(expected_team_score, scores)).round(3)
  end

  def self.calculate_boost(expected_team_score, scores)
    return (self.multiplier(expected_team_score, scores)*100).round()
  end

  def self.multiplier(score, scores)
    if (0 == score)
      return 0
    else
      return ((score - scores.mean)/scores.mean)
    end
  end

  def self.get_expected_scores(import)
    overunders = {:scores => []}

    OverUnder.where({:import => import}).each do |overunder|
      home    = OverUnder.translate(import.league, overunder.home)
      visitor = OverUnder.translate(import.league, overunder.visitor)

      if (overunder.overunder > overunder.home_spread.abs)
        h_score = (overunder.overunder - overunder.home_spread)/2
      else
        p_win   = OverUnder.moneyline_to_decimal(overunder.home_spread)
        h_score = (overunder.overunder*p_win).round(2)
      end

      v_score = (overunder.overunder - h_score)
      overunders[home]    = {:opp => visitor, :score => h_score}
      overunders[visitor] = {:opp => home,    :score => v_score}

      if (0 != overunder.overunder)
        overunders[:scores] << h_score
        overunders[:scores] << v_score
      end
    end

    return overunders
  end
end
