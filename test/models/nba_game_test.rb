require 'test_helper'

class NbaGameTest < ActiveSupport::TestCase
  def setup
    json_string = <<-EOF
       {
        "resource":"playergamelog",
        "parameters":{"PlayerID":201143},
        "resultSets":[
          {
            "name":"PlayerGameLog",
            "headers":["SEASON_ID","Player_ID","Game_ID","GAME_DATE","MATCHUP","MIN","REB","AST","STL","BLK","TOV","PTS","VIDEO_AVAILABLE"],
            "rowSet":[
               ["22014",201143,"0021400568","JAN 13, 2015","ATL @ PHI",29,10,10,0,1,2,21,1],
               ["22014",201143,"0021400558","JAN 11, 2015","ATL vs. WAS",30,6,3,1,2,0,15,1]
            ]
          }
        ]
       }
    EOF
    @json_data = JSON.parse(json_string)
    @gamelogs = NbaGame.parse_json(@json_data)
    @nbagame0 = NbaGame.new(@gamelogs[0])
    @nbagame1 = NbaGame.new(@gamelogs[1])
  end

  test "json parsing" do
    assert_equal(2, @gamelogs.size)
    assert_equal("22014",  @gamelogs[0]["season_id"])
    assert_equal("0021400568", @gamelogs[0]["game_id"])
    assert_equal(201143, @gamelogs[0]["nba_player_id"])
    assert_equal("JAN 13, 2015", @gamelogs[0]["game_date"])
    assert_equal(29, @gamelogs[0]["minutes"])
    assert_equal(10, @gamelogs[0]["rebounds"])
    assert_equal(21, @gamelogs[0]["points"])
    assert_equal(10, @gamelogs[0]["assists"])
    assert_equal(2, @gamelogs[0]["turnovers"])
    assert_equal(1, @gamelogs[0]["blocks"])
    assert_equal(0, @gamelogs[0]["steals"])
    assert_equal("ATL @ PHI", @gamelogs[0]["matchup"])
    assert_equal(12, @gamelogs[0].keys.size)
  end

  test "matchup parsing" do
    assert_equal("ATL", @nbagame0.visitor)
    assert_equal("PHI", @nbagame0.home)
    assert_equal("WAS", @nbagame1.visitor)
    assert_equal("ATL", @nbagame1.home)
  end

  test "date parsing" do
    assert(Date.today > @nbagame0.game_date)
    assert(@nbagame0.game_date > @nbagame1.game_date)
  end

  test "fan duel points" do
    assert_equal(48, @nbagame0.fan_duel_points)
    assert_equal(32.7, @nbagame1.fan_duel_points)
  end
end