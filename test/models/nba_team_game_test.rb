require 'test_helper'

class NbaTeamGameTest < ActiveSupport::TestCase
  def setup
    json_string = <<-EOF
      {
        "resource":"teamgamelog",
        "parameters":
        {
          "TeamID":1610612747,
          "LeagueID":"00",
          "Season":"2014-15",
          "SeasonType":"Regular Season"
        },
        "resultSets":
        [
          {
            "name":"TeamGameLog",
            "headers":
            [
              "Team_ID",
              "Game_ID",
              "GAME_DATE",
              "MATCHUP",
              "WL",
              "MIN"
            ],
            "rowSet":
            [
              [
                1610612747,
                "0021400622",
                "JAN 19, 2015",
                "LAL @ PHX",
                "L",
                240
              ],
              [
                1610612747,
                "0021400597",
                "JAN 16, 2015",
                "LAL vs. CHA",
                "W",
                240
              ]
            ]
          }
        ]
      }
    EOF
    @json_data = JSON.parse(json_string)
    @teamgamelogs = NbaTeamGame.parse_json(@json_data)
    @teamgame0 = NbaTeamGame.new(@teamgamelogs[0])
    @teamgame1 = NbaTeamGame.new(@teamgamelogs[1])
  end

  test "json parsing" do
    assert_equal(2, @teamgamelogs.size)
    assert_equal(1610612747, @teamgamelogs[0]["nba_team_id"])
    assert_equal("0021400622", @teamgamelogs[0]["game_id"])
    assert_equal("JAN 19, 2015", @teamgamelogs[0]["game_date"])
    assert_equal(240, @teamgamelogs[0]["minutes"])
    assert_equal("LAL @ PHX", @teamgamelogs[0]["matchup"])
    assert_equal("L", @teamgamelogs[0]["winloss"])
    assert_equal(6, @teamgamelogs[0].keys.size)
  end

  test "matchup parsing" do
    assert_equal("LAL", @teamgame0.visitor)
    assert_equal("PHX", @teamgame0.home)
    assert_equal("CHA", @teamgame1.visitor)
    assert_equal("LAL", @teamgame1.home)
  end

  test "date parsing" do
    assert(Date.today > @teamgame0.game_date)
    assert(@teamgame0.game_date > @teamgame1.game_date)
  end

  test "win parsing" do
    assert_equal(false, @teamgame0.win)
    assert_equal(true, @teamgame1.win)
  end
end
