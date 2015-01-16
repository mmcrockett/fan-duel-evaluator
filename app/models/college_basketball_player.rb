class CollegeBasketballPlayer < FanDuelPlayer
  MAX_GAMES = 10
  MAX_DATES = (MAX_GAMES * 4).to_i

  POSITIONS  = ["F","F","F","F","F","G","G","G","G"]
  BUDGET     = 60000

  ANALYZE_COLUMNS = [:avg, :expp]

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
    927 => "CREIG",
    784 => "WSTVA",
    739 => "LSU",
    777 => "VANDB",
    717 => "BAYLR",
    734 => "IOWST",
    715 => "ARK",
    746 => "MISSP",
    919 => "TCU",
    755 => "OKLA",
    761 => "PROV",
    771 => "TEX",
    718 => "BOSTC",
    735 => "KANS",
    726 => "FLORI",
    748 => "MISSR",
    737 => "KTCKY",
    765 => "SOCAR",
    721 => "CLEMS",
    954 => "UTEP",
    713 => "ARZNA",
    726 => "FLORI",
    781 => "WAKE",
    753 => "NDAME",
    762 => "PURDU",
    716 => "AUBRN",
    856 => "XAV",
    736 => "KANST",
    772 => "TEXAM",
    782 => "WASH",
    755 => "OKLA",
    784 => "WSTVA",
    751 => "NCSTA",
    1104 => "TEMPL",
    735 => "KANS",
    742 => "MIAMI",
    761 => "PROV",
    719 => "CAL",
    785 => "WISCN",
    782 => "WASH",
    956 => "TLANE",
    747 => "MISST",
    727 => "FLAST",
    776 => "UTAH",
    775 => "USC",
    719 => "CAL",
    782 => "WASH",
    722 => "CLRDO",
    774 => "UCLA",
    734 => "IOWST",
    765 => "SOCAR",
    1125 => "MEMPH",
    956 => "TLANE",
    766 => "SOFLA",
    821 => "ECAR",
    763 => "RUTG",
    759 => "PENST",
    757 => "ORGN",
    758 => "ORGST",
    721 => "CLEMS",
    750 => "UNC",
    750 => "UNC",
    732 => "INDNA",
    749 => "NEB",
  }

  def important?
    return (8 < self.average)
  end
end
