class Weather
  DATE_FORMAT = "%H%M"
  BASE_URL    = "https://www.fanduel.com/weather/"

  def initialize(fixtures, teams = {})
    @data = []

    fixtures.each do |fixture|
      @data << FanDuelFixture.new(fixture, teams)
    end
  end

  def url
    url = "#{BASE_URL}"

    @data.each_with_index do |f, i|
      if (0 == i)
        url += "#{f.gametime.strftime("%Y/%m/%d")}/"
      else
        url += ","
      end

      url += "#{f.visitor_team}@#{f.home_team}@#{f.gametime.strftime("%H%M")}"
    end

    return url
  end
end
