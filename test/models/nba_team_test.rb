require 'test_helper'

class NbaTeamTest < ActiveSupport::TestCase
  def setup
    json_string = <<-EOF
       {"resource":"leaguedashteamstats",
        "parameters": {"StarterBench":null},
        "resultSets":[
          {
           "name":"LeagueDashTeamStats",
           "headers":["TEAM_ID","TEAM_NAME","GP","W","OFF_RATING","DEF_RATING","PACE","CFPARAMS"],
           "rowSet":[
              [1610612737,"Atlanta Hawks",37,29,106.2,100.1,96.45,"Atlanta Hawks"],
              [1610612738,"Boston Celtics",36,13,101.3,102.9,99.61,"Boston Celtics"]
           ]
          }
        ]
       }
    EOF
    @json_data = JSON.parse(json_string)
  end

  test "json parsing" do
    rows = NbaTeam.parse_json(@json_data)
    hawks = rows[0]

    assert_equal(2, rows.size)
    assert_equal("Atlanta Hawks", hawks["name"])
    assert_equal(1610612737, hawks["id"])
    assert_equal(37, hawks["gp"])
    assert_equal(106.2, hawks["off_rating"])
    assert_equal(100.1, hawks["def_rating"])
    assert_equal(96.45, hawks["pace"])
  end
end
