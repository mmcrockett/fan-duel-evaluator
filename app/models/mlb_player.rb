require 'open-uri'

class MlbPlayer < FanDuelPlayer
  MAX_GAMES = 10
  MAX_DATES = (MAX_GAMES * 2.2).to_i

  POSITIONS  = ["P","C","1B","2B","3B","SS","OF","OF","OF"]
  BUDGET     = 35000

  ANALYZE_COLUMNS = [:expmean, :expavg, :expmed]

  TEAMS_BY_FD_ID = {
    593 => "NYY",
    606 => "MIA",
    609 => "WAS",
    594 => "TAM",
    608 => "PHI",
    591 => "BAL",
    595 => "TOR",
    607 => "NYM",
    597 => "CLE",
    610 => "CHC",
    605 => "ATL",
    592 => "BOS",
    611 => "CIN",
    598 => "DET",
    596 => "CWS",
    614 => "PIT",
    599 => "KAN",
    613 => "MIL",
    600 => "MIN",
    615 => "STL",
    617 => "COL",
    612 => "HOU",
    616 => "ARI",
    601 => "LAA",
    602 => "OAK",
    619 => "SDP",
    603 => "SEA",
    620 => "SFG",
    618 => "LOS",
    604 => "TEX",
  }

  def important?
    if ("P" == self.position)
      if ((5 == self.status) || (1 == self.status))
        return true
      else
        return false
      end
    end

    if (self.avg < 2)
      return false
    end

    if (true == status.include?("DL"))
      return false
    end

    return true
  end
end
