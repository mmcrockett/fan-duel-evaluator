require 'open-uri'

class NhlPlayer < FanDuelPlayer
  @@starting_goalies = []

  MAX_GAMES = 10
  MAX_DATES = (MAX_GAMES * 2.2).to_i

  STARTING_GOALIE_URI = "http://www2.dailyfaceoff.com/starting-goalies/"

  TEAMS_BY_FD_ID = {
    649 => "ANH",
    650 => "WPG",
    651 => "BOS",
    652 => "BUF",
    653 => "CGY",
    654 => "CAR",
    655 => "CHI",
    656 => "COL",
    657 => "CLS",
    658 => "DAL",
    659 => "DET",
    660 => "EDM",
    661 => "FLA",
    662 => "LA",
    663 => "MIN",
    664 => "MON",
    665 => "NSH",
    666 => "NJ",
    667 => "NYI",
    668 => "NYR",
    669 => "OTT",
    670 => "PHI",
    671 => "ARI",
    672 => "PIT",
    673 => "SJ",
    674 => "STL",
    675 => "TB",
    676 => "TOR",
    677 => "VAN",
    678 => "WAS",
  }

  def important?
    if (0 == @@starting_goalies.size)
      set_starting_goalies
    end

    if (3800 > self.cost)
      return false
    else
      if ("D" == self.position)
        return (1 < self.average)
      elsif ("G" == self.position)
        if (false == @@starting_goalies.include?(last_name(self.name)))
          self.ignore = true

          return (6500 <= self.cost)
        else
          return true
        end
      else
        return (1.2 < self.average)
      end
    end
  end

  private
  def set_starting_goalies
    page = Nokogiri::HTML(open("#{STARTING_GOALIE_URI}"))
    page.css('img.headshot').each do |img_tag|
      @@starting_goalies << last_name(img_tag['alt'])
    end
  end

  def last_name(name)
    if (true == name.include?(','))
      return name.split(',')[0]
    elsif (true == name.include?(' '))
      return name.split(' ')[1]
    else
      return name
    end
  end
end
