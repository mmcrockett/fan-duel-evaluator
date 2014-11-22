require 'open-uri'

class NhlPlayer < FanDuelPlayer
  @@starting_goalies     = []
  @@unconfirmed_goalies  = []

  MAX_GAMES = 10
  MAX_DATES = (MAX_GAMES * 2.2).to_i

  POSITIONS  = ["LW","LW","RW","RW","C","C","D","D","G"]
  BUDGET     = 55000

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
        lname = unified_name(self.name)
        if (false == @@starting_goalies.include?(unified_name(self.name)))
          self.ignore = true

          return (6500 <= self.cost)
        else
          if (true == @@unconfirmed_goalies.include?(unified_name(self.name)))
            self.note = "?#{self.note}"
          end
          return true
        end
      else
        return (1.2 < self.average)
      end
    end
  end

  def unified_name(name)
    first_name = ""
    last_name  = ""

    if (true == name.include?(','))
      first_name = name.split(',')[1].strip
      last_name  = name.split(',')[0].strip
    elsif (true == name.include?(' '))
      first_name = name.split(' ')[0].strip
      last_name  = name.split(' ')[1].strip
    else
      last_name  = name
    end

    return "#{first_name[0]}#{last_name}"
  end

  private
  def set_starting_goalies
    page = Nokogiri::HTML(open("#{STARTING_GOALIE_URI}"))
    page.css('img.headshot').each do |img_tag|
      @@starting_goalies << unified_name(img_tag['alt'])
    end
    page.css('script').each do |script_tag|
      script_text = script_tag.text()
      if (true == script_text.include?("alt"))
        end_part  = script_text[script_text.index(" alt=")..-1]
        name_part = end_part.split('\"', 3)[1]

        if (false == @@starting_goalies.include?(unified_name(name_part)))
          @@starting_goalies    << unified_name(name_part)
          @@unconfirmed_goalies << unified_name(name_part)
        end
      end
    end
  end
end
