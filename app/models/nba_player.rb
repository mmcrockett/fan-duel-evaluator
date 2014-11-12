class NbaPlayer < FanDuelPlayer
  MAX_GAMES = 12

  TEAMS_BY_FD_ID = {
    679 => "ATL",
    680 => "BOS",
    681 => "CHA",
    682 => "CHI",
    683 => "CLE",
    684 => "DAL",
    685 => "DEN",
    686 => "DET",
    687 => "GS",
    688 => "HOU",
    689 => "IND",
    690 => "LAC",
    691 => "LAL",
    692 => "MEM",
    694 => "MIL",
    695 => "MIN",
    696 => "BKN",
    697 => "NO",
    698 => "NY",
    699 => "OKC",
    700 => "ORL",
    701 => "PHI",
    702 => "PHO",
    703 => "POR",
    704 => "SAC",
    705 => "SA",
    706 => "TOR",
    707 => "UTA",
    708 => "WAS",
  }

  def valid?
    return (8 < self.average)
  end
end
