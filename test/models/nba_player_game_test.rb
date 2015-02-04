require 'test_helper'

class NbaPlayerGameTest < ActiveSupport::TestCase
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
    @rows     = NbaPlayerGame.parse_json(@json_data)
    @nbagame0 = NbaPlayerGame.new(@rows[0])
    @nbagame1 = NbaPlayerGame.new(@rows[1])
  end

  test "json parsing" do
    assert_equal(2, @rows.size)
    assert_equal("22014",  @rows[0]["assigned_season_id"])
    assert_equal("0021400568", @rows[0]["assigned_game_id"])
    assert_equal("ATL @ PHI", @rows[0]["matchup"])
    assert_equal("JAN 13, 2015", @rows[0]["game_date_str"])
    assert_equal(29, @rows[0]["minutes"])
    assert_equal(10, @rows[0]["rebounds"])
    assert_equal(21, @rows[0]["points"])
    assert_equal(10, @rows[0]["assists"])
    assert_equal(2, @rows[0]["turnovers"])
    assert_equal(1, @rows[0]["blocks"])
    assert_equal(0, @rows[0]["steals"])
    assert_equal(11, @rows[0].keys.size)
  end

  test "json to active record" do
    assert_equal("22014",  @nbagame0.assigned_season_id)
    assert_equal("0021400568", @nbagame0.assigned_game_id)
    assert_equal(29, @nbagame0.minutes)
    assert_equal(10, @nbagame0.rebounds)
    assert_equal(21, @nbagame0.points)
    assert_equal(10, @nbagame0.assists)
    assert_equal(2, @nbagame0.turnovers)
    assert_equal(1, @nbagame0.blocks)
    assert_equal(0, @nbagame0.steals)
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

  test "remote load" do
    NbaPlayer.stubs(:all).returns([NbaPlayer.new({:id => -1, :assigned_player_id => 201143})])

    gamenewest = @rows[0]
    gametoday  = @rows[0].clone
    gametoday["game_date_str"] = Date.today.strftime("%b %d, %Y")
    gameoldest = @rows[1]

    NbaPlayerGame.stubs(:get_data).returns([gamenewest,gametoday])
    NbaPlayerGame.remote_load
    assert_equal(1, NbaPlayerGame.where({:nba_player_id => -1}).size)
    assert_equal(29, NbaPlayerGame.where({:assigned_game_id => "0021400568"}).first.minutes)

    NbaPlayerGame.stubs(:get_data).returns([gameoldest,gamenewest,gametoday])
    NbaPlayerGame.remote_load
    assert_equal(1, NbaPlayerGame.where({:nba_player_id => -1}).size)
    assert_equal(29, NbaPlayerGame.where({:assigned_game_id => "0021400568"}).first.minutes)
  end

  test "remote load multiple" do
    NbaPlayer.stubs(:all).returns([NbaPlayer.new({:id => -2, :assigned_player_id => 201143})])

    NbaPlayerGame.stubs(:get_data).returns(@rows)
    NbaPlayerGame.remote_load
    assert_equal(2, NbaPlayerGame.where({:nba_player_id => -2}).size)
    assert_equal(29, NbaPlayerGame.where({:assigned_game_id => "0021400568"}).first.minutes)
    assert_equal(30, NbaPlayerGame.where({:assigned_game_id => "0021400558"}).first.minutes)
  end
end
