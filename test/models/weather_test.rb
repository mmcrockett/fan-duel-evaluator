require 'test_helper'

class WeatherTest < ActiveSupport::TestCase
  PLAYER_JSON        = "#{File.open("test/fixtures/fd_players.json").read()}"

  test "weather urls" do
    data = JSON.parse(PLAYER_JSON)
    fixtures = data["fixtures"]
    teams    = Import.convert_teams(data)
    expected_url = "https://www.fanduel.com/weather/2015/06/29/COL@OAK@2205,LOS@ARI@2140,KAN@HOU@2010,NYY@LAA@2205,TEX@BAL@1905,MIL@PHI@1905,BOS@TOR@1907,MIN@CIN@1910,CLE@TAM@1910"

    weather = Weather.new(fixtures, teams)

    assert_equal(expected_url, weather.url)
  end
end
