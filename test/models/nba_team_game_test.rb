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
    @rows = NbaTeamGame.parse_json(@json_data)
    @teamgame0 = NbaTeamGame.new(@rows[0])
    @teamgame1 = NbaTeamGame.new(@rows[1])
  end

  test "json parsing" do
    assert_equal(2, @rows.size)
    assert_equal("0021400622", @rows[0]["assigned_game_id"])
    assert_equal("JAN 19, 2015", @rows[0]["game_date_str"])
    assert_equal(240, @rows[0]["minutes"])
    assert_equal("LAL @ PHX", @rows[0]["matchup"])
    assert_equal("L", @rows[0]["winloss"])
    assert_equal(5, @rows[0].keys.size)
  end

  test "json to active record" do
    assert_equal("0021400622", @teamgame0.assigned_game_id)
    assert_equal(240, @teamgame0.minutes)
  end

  test "matchup parsing" do
    assert_equal("LAL", @teamgame0.visitor)
    assert_equal("PHX", @teamgame0.home)
    assert_equal("CHA", @teamgame1.visitor)
    assert_equal("LAL", @teamgame1.home)
  end

  test "date parsing" do
    tg0 = NbaTeamGame.new(@rows[0])
    tg1 = NbaTeamGame.new(@rows[0])
    tg0.game_date = "OCT 31, 2014"
    tg1.game_date = "DEC 01, 2014"
    team_games = [@teamgame0, @teamgame1, tg0, tg1]

    assert(Date.today > @teamgame0.game_date)
    assert(@teamgame0.game_date > @teamgame1.game_date)

    team_games.each do |t|
      t.nba_team_id = 1
    end

    NbaTeamGame.import(team_games)
    assert_equal("2014-10-31", "#{NbaTeamGame.maximum(:game_date)}")
    assert_equal("2015-01-16", "#{NbaTeamGame.minimum(:game_date)}")
  end

  test "win parsing" do
    assert_equal(false, @teamgame0.win)
    assert_equal(true, @teamgame1.win)
  end

  test "remote load" do
    NbaTeam.stubs(:all).returns([NbaTeam.new({:id => -1, :assigned_team_id => 1610612738})])

    gamenewest = @rows[0]
    gametoday  = @rows[0].clone
    gametoday["game_date_str"] = Date.today.strftime("%b %d, %Y")
    gameoldest = @rows[1]

    NbaTeamGame.stubs(:get_data).returns([gamenewest,gametoday])
    NbaTeamGame.remote_load
    assert_equal(1, NbaTeamGame.all.size)
    assert_equal(false, NbaTeamGame.where({:assigned_game_id => "0021400622"}).first.win)

    NbaTeamGame.stubs(:get_data).returns([gameoldest,gamenewest,gametoday])
    NbaTeamGame.remote_load
    assert_equal(1, NbaTeamGame.all.size)
    assert_equal(false, NbaTeamGame.where({:assigned_game_id => "0021400622"}).first.win)
  end

  test "remote load multiple" do
    NbaTeam.stubs(:all).returns([NbaTeam.new({:id => -2, :assigned_team_id => 1610612738})])

    NbaTeamGame.stubs(:get_data).returns(@rows)
    NbaTeamGame.remote_load
    assert_equal(2, NbaTeamGame.all.size)
    assert_equal(false, NbaTeamGame.where({:assigned_game_id => "0021400622"}).first.win)
    assert_equal(true, NbaTeamGame.where({:assigned_game_id => "0021400597"}).first.win)
  end
end
