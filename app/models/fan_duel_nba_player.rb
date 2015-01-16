require 'uri'
require 'open-uri'

class FanDuelNbaPlayer < FanDuelPlayer
  MAX_GAMES = 10
  MAX_DATES = (MAX_GAMES * 2.2).to_i

  POSITIONS  = ["PG","PG","SG","SG","SF","SF","PF","PF","C"]
  BUDGET     = 60000

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
    693 => "MIA",
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

  def important?
    return (8 < self.average)
  end
end
