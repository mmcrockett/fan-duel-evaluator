require 'test_helper'

class PlayerFinderTest < ActiveSupport::TestCase
  def setup
    sort_column = :avg
    players     = FanDuelPlayer.player_data({:league => "NFL", :ignore => false})
    sorted_players = FanDuelPlayer.sort(players, sort_column)

    @player_finder = PlayerFinder.new(sorted_players)
  end

  test "find_value" do
    value_wr = @player_finder.find_value("WR")
    n0_wr = @player_finder.find_value("WR", {:exclude => [value_wr]})
    max_cost_wr = @player_finder.find_value("WR", {:exclude => [value_wr], :max_cost => 5000})

    assert_equal(2649,value_wr.id)
    assert_equal(2682,n0_wr.id)
    assert_equal(2875,max_cost_wr.id)
  end

  test "find_best" do
    best_wr = @player_finder.find_best("WR")
    n0_wr = @player_finder.find_best("WR", {:exclude => [best_wr]})
    n1_wr = @player_finder.find_best("WR", {:exclude => [best_wr, n0_wr]})
    max_cost_wr = @player_finder.find_best("WR", {:exclude => [best_wr, n0_wr, n1_wr], :max_cost => 5500})

    assert_equal(2634,best_wr.id)
    assert_equal(2632,n0_wr.id)
    assert_equal(2682,n1_wr.id)
    assert_equal(2649,max_cost_wr.id)
  end

  test "no valid player exception" do
    assert_raise PlayerFinderValidPlayerNotFoundException do |x|
      @player_finder.find_best("WR", {:max_cost => 0})
    end

    assert_raise PlayerFinderValidPlayerNotFoundException do |x|
      @player_finder.find_value("WR", {:max_cost => 0})
    end
  end
end
