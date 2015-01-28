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
    @rows = NbaPlayer.parse_json(@json_data)
    @p0   = NbaPlayer.new(@rows[0])
  end

  test "json parsing" do
    assert_equal(2, @rows.size)
    assert_equal("Avery Bradley", @rows[0]["name"])
    assert_equal(202340, @rows[0]["assigned_player_id"])
    assert_equal(2, @rows[0].keys.size)
  end

  test "json to active record" do
    assert_equal("Avery Bradley", @p0.name)
    assert_equal(202340, @p0.assigned_player_id)
  end

  test "remote load" do
    NbaTeam.stubs(:all).returns([NbaTeam.new({:id => -1, :assigned_team_id => 1610612738})])
    bradley_original = @rows[0]
    thornton_original = @rows[1]
    NbaPlayer.stubs(:get_data).returns([bradley_original])
    NbaPlayer.remote_load
    assert_equal(1, NbaPlayer.where({:nba_team_id => -1}).size)
    assert_equal(-1, NbaPlayer.where({:assigned_player_id => 202340}).first.nba_team_id)
    assert_equal("Avery Bradley", NbaPlayer.where({:assigned_player_id => 202340}).first.name)

    NbaTeam.stubs(:all).returns([NbaTeam.new({:id => -2, :assigned_team_id => 1610612738})])
    NbaPlayer.stubs(:get_data).returns([bradley_original, thornton_original])
    NbaPlayer.remote_load
    assert_equal(2, NbaPlayer.where({:nba_team_id => -2}).size)
    assert_equal(-2, NbaPlayer.where({:assigned_player_id => 202340}).first.nba_team_id)
    assert_equal("Avery Bradley", NbaPlayer.where({:assigned_player_id => 202340}).first.name)
    assert_equal(-2, NbaPlayer.where({:assigned_player_id => 201977}).first.nba_team_id)
    assert_equal("Marcus Thornton", NbaPlayer.where({:assigned_player_id => 201977}).first.name)
  end

  test "name lookup" do
    assert_not_nil(NbaPlayer.lookup_by_fd_player(FanDuelNbaPlayer.new({:name => "Darren Collison"})))
    assert_not_nil(NbaPlayer.lookup_by_fd_player(FanDuelNbaPlayer.new({:name => "J.J. Redick"})))
    assert_not_nil(NbaPlayer.lookup_by_fd_player(FanDuelNbaPlayer.new({:name => "Luc Richard Mbah a Moute"})))
    assert_nil(NbaPlayer.lookup_by_fd_player(FanDuelNbaPlayer.new({:name => "Michael Crockett"})))
  end
end
