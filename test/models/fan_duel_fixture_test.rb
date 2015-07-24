require 'test_helper'

class FanDuelFixtureTest < ActiveSupport::TestCase
  PLAYER_JSON        = "#{File.open("test/fixtures/fd_players.json").read()}"

  def setup
    data = JSON.parse(PLAYER_JSON)
    @fixture = data["fixtures"][0]
  end

  test "parsing fd fixtures" do
    f = FanDuelFixture.new(@fixture)
    expected_gametime = Time.strptime("2015-06-29 22:05:00 EDT", "%Y-%m-%d %H:%M:%S %Z")

    assert_equal(602, f.home_team_id)
    assert_equal(617, f.visitor_team_id)
    assert_equal(expected_gametime, f.gametime)
    assert_equal(expected_gametime.in_time_zone("America/New_York").strftime("%H%M"),f.gametime.strftime("%H%M"))

    assert_raise RuntimeError do |x|
      f.visitor_team
    end
  end

  test "bad data" do
    valid_visitor = FanDuelFixture.new(@fixture, {617 => "VISITOR_TEAM"})
    valid_home    = FanDuelFixture.new(@fixture, {602 => "HOME_TEAM"})

    assert_raise RuntimeError do |x|
      valid_home.visitor_team
    end

    assert_equal("HOME_TEAM", valid_home.home_team)

    assert_raise RuntimeError do |x|
      valid_visitor.home_team
    end

    assert_equal("VISITOR_TEAM", valid_visitor.visitor_team)
  end
end
