require 'test_helper'

class NbaTeamTest < ActiveSupport::TestCase
  def setup
    json_string = <<-EOF
       {"resource":"leaguedashteamstats",
        "parameters":{"StarterBench":null},
        "resultSets":[
          {
           "name":"LeagueDashTeamStats",
           "headers":["TEAM_ID","TEAM_NAME","GP","W","OFF_RATING","DEF_RATING","PACE","CFPARAMS"],
           "rowSet":[
              [1610612737,"Atlanta Hawks",37,29,106.2,100.1,96.45,"Atlanta Hawks"],
              [1610612738,"Los Angeles Lakers",36,13,101.3,102.9,99.61,"Los Angeles Lakers"]
           ]
          }
        ]
       }
    EOF
    @json_data = JSON.parse(json_string)
    @rows = NbaTeam.parse_json(@json_data)
  end

  test "json parsing" do
    hawks = @rows[0]

    assert_equal(2, @rows.size)
    assert_equal("Atlanta Hawks", hawks["name"])
    assert_equal(1610612737, hawks["assigned_team_id"])
    assert_equal(37, hawks["gp"])
    assert_equal(106.2, hawks["off_rating"])
    assert_equal(100.1, hawks["def_rating"])
    assert_equal(96.45, hawks["pace"])
    assert_equal(6, hawks.keys.size)
  end

  test "json to active record" do
    hawks = NbaTeam.new(@rows[0])

    assert_equal("Atlanta Hawks", hawks.name)
    assert_equal(1610612737, hawks.assigned_team_id)
    assert_equal(37, hawks.gp)
    assert_equal(106.2, hawks.off_rating)
    assert_equal(100.1, hawks.def_rating)
    assert_equal(96.45, hawks.pace)
  end

  test "nickname" do
    assert_equal("ATL", NbaTeam.new(@rows[0]).nickname)
    assert_equal("LAL", NbaTeam.new(@rows[1]).nickname)
  end

  test "remote load" do
    hawks_original = @rows[0]
    hawks_modified = @rows[0].clone
    hawks_modified["gp"] = 50
    lakers_original = @rows[1]
    NbaTeam.stubs(:get_data).returns([hawks_original])
    NbaTeam.remote_load
    assert_equal(1, NbaTeam.where({:name => hawks_original["name"]}).size)
    assert_equal(37, NbaTeam.where({:assigned_team_id => 1610612737}).first.gp)
    NbaTeam.stubs(:get_data).returns([hawks_modified, lakers_original])
    NbaTeam.remote_load
    assert_equal(2, NbaTeam.where({:name => [hawks_original["name"], lakers_original["name"]]}).size)
    assert_equal(50, NbaTeam.where({:assigned_team_id => 1610612737}).first.gp)
    assert_equal(36, NbaTeam.where({:assigned_team_id => 1610612738}).first.gp)
  end
end
