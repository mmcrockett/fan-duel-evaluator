require 'test_helper'

class NbaPlayerTest < ActiveSupport::TestCase
  def setup
    json_string = <<-EOF
      {
        "resource":"commonteamroster",
        "parameters":
        {
          "TeamID":1610612738,
          "LeagueID":"00",
          "Season":"2014-15"
        },
        "resultSets":
        [
          {
            "name":"CommonTeamRoster",
            "headers":
            [
              "TeamID",
              "SEASON",
              "PLAYER",
              "NUM",
              "POSITION",
              "PLAYER_ID"
            ],
            "rowSet":
            [
              [
                1610612738,
                "2014",
                "Avery Bradley",
                "0",
                "G",
                202340
              ],
              [
                1610612738,
                "2014",
                "Marcus Thornton",
                "4",
                "G",
                201977
              ]
            ]
          }
        ]
      }
    EOF
    @json_data = JSON.parse(json_string)
  end

  test "json parsing" do
    rows = NbaPlayer.parse_json(@json_data)
    p0 = rows[0]

    assert_equal(2, rows.size)
    assert_equal("Avery Bradley", p0["name"])
    assert_equal(202340, p0["id"])
    assert_equal(2, p0.keys.size)
  end
end
