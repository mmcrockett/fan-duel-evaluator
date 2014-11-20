require 'test_helper'

class SimpleRosterTest < ActiveSupport::TestCase
  def setup
    players = FanDuelPlayer.player_data({:league => "NFL"})
    @sorted_players = FanDuelPlayer.sort(players, :avg)
  end

  test "add_player" do
    sroster = SimpleRoster.new(@sorted_players.first.class::MAX_SALARY)
    sroster << @sorted_players.first
    assert_equal(sroster.cost, @sorted_players.first.cost)
    assert_equal(sroster.points, @sorted_players.first.avg)
    assert_equal(sroster.players, [@sorted_players.first])
  end

  test "fail_too_many" do
    sroster = SimpleRoster.new(@sorted_players.first.class::MAX_SALARY)

    assert_raise SimpleRosterSizeException do |x|
      10.times do |i|
        sroster << @sorted_players[-i]
      end
    end
  end

  test "fail_too_expensive" do
    sroster = SimpleRoster.new(@sorted_players.first.class::MAX_SALARY)

    assert_raise SimpleRosterBudgetException do |x|
      9.times do |i|
        sroster << @sorted_players[i]
      end
    end
  end
end
