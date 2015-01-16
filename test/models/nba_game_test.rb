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
  end

  test "json parsing" do
    rows = NbaGame.parse_json(@json_data)
    game_log = rows[0]

    assert_equal(2, rows.size)
    assert_equal("22014",  game_log["season_id"])
    assert_equal("0021400568", game_log["game_id"])
    assert_equal(201143, game_log["nba_player_id"])
    assert_equal("JAN 13, 2015", game_log["game_date"])
    assert_equal(29, game_log["minutes"])
    assert_equal(10, game_log["rebounds"])
    assert_equal(21, game_log["points"])
    assert_equal(10, game_log["assists"])
    assert_equal(2, game_log["turnovers"])
    assert_equal(1, game_log["blocks"])
    assert_equal(0, game_log["steals"])
    assert_equal("ATL @ PHI", game_log["matchup"])
    assert_equal(12, game_log.keys.size)
  end

  test "matchup parsing" do
    rows = NbaGame.parse_json(@json_data)

    assert_equal(2, rows.size)

    p0 = NbaGame.new(rows[0])
    p1 = NbaGame.new(rows[1])

    assert_equal("ATL", p0.visitor)
    assert_equal("PHI", p0.home)
    assert_equal("WAS", p1.visitor)
    assert_equal("ATL", p1.home)
  end
end
