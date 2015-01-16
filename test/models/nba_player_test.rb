require 'test_helper'

class NbaPlayerTest < ActiveSupport::TestCase
  def setup
    json_string = <<-EOF
       {"resource":"teamplayerdashboard",
        "parameters":{"MeasureType":"Advanced"},
        "resultSets":[
          {
           "name":"TeamOverall",
           "headers":["TEAM_ID","TEAM_NAME","GP","OFF_RATING","DEF_RATING","PACE","PIE"],
            "rowSet":[[1610612737,"Atlanta Hawks",38,106.2,99.9,96.44,0.548]]
          },
          {
           "name":"PlayersSeasonTotals",
           "headers":["GROUP_SET","PLAYER_ID","PLAYER_NAME","PIE"],
           "rowSet":[
              ["Players",201143,"Al Horford",0.134],
              ["Players",201960,"DeMarre Carroll",0.087]
           ]
          }
        ]
       }
    EOF
    @json_data = JSON.parse(json_string)
  end

  test "json parsing" do
    rows = NbaPlayer.parse_json(@json_data)
    horford = rows[0]

    assert_equal(2, rows.size)
    assert_equal("Al Horford", horford["name"])
    assert_equal(201143, horford["id"])
    assert_equal(2, horford.keys.size)
  end
end
