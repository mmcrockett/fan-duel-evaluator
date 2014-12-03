class CollegeBasketballPlayer < FanDuelPlayer
  MAX_GAMES = 10
  MAX_DATES = (MAX_GAMES * 2.2).to_i

  POSITIONS  = ["F","F","F","F","F","G","G","G","G"]
  BUDGET     = 60000

  ANALYZE_COLUMNS = [:med]

  TEAMS_BY_FD_ID = {
    716 => "AUBRN",
    725 => "DUKE",
    730 => "GTECH",
    733 => "IOWA",
    741 => "MRLND",
    744 => "MCHST",
    750 => "UNC",
    752 => "NWEST",
    753 => "NDAME",
    759 => "PENST",
    773 => "TXTCH",
    779 => "VIRG",
    780 => "VTECH",
    785 => "WISCN",
    921 => "TULSA",
    927 => "CREIG"
  }

  def important?
    return (8 < self.average)
  end
end
