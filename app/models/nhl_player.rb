class NhlPlayer < FanDuelPlayer
  MAX_GAMES = 12

  TEAMS_BY_FD_ID = {
    649 => "ANH",
    650 => "WPG",
    651 => "BOS",
    652 => "?",
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
    664 => "?",
    665 => "NSH",
    666 => "NJ",
    667 => "NYI",
    668 => "?",
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

  def valid
    if (3800 > self.cost)
      return false
    else
      if ("D" == self.position)
        return (1 < self.average)
      elsif ("G" == self.position)
        return (7000 < self.cost)
      else
        return (1.2 < self.average)
      end
    end
  end
end