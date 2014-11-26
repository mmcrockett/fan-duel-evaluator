require 'test_helper'

class FanDuelPlayerTest < ActiveSupport::TestCase
  def setup
    @players = []
    @players << FanDuelPlayer.new({
      :id        => 0,
      :name      => "Max Avg",
      :position  => "X",
      :average   => 50,
      :cost      => 100,
      :game_data => [10,30,20,40],
      :game_log_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 1,
      :name      => "High Min",
      :position  => "X",
      :average   => 2,
      :cost      => 100,
      :game_data => [22,22,22,22],
      :game_log_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 2,
      :name      => "Z",
      :position  => "X",
      :average   => 5,
      :cost      => 100,
      :game_data => [30,28,25,-2],
      :game_log_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 3,
      :name      => "All Zero",
      :position  => "X",
      :average   => 0,
      :cost      => 100,
      :game_data => [0,0,0,0],
      :game_log_loaded => true})
  end

  test "default everything" do
    sorted_players = FanDuelPlayer.sort(@players, :avg)

    assert_equal(0, sorted_players[0].id)
    assert_equal(2, sorted_players[1].id)
    assert_equal(1, sorted_players[2].id)
    assert_equal(3, sorted_players[3].id)
  end

  test "override default sort for number" do
    sorted_players = FanDuelPlayer.sort(@players, :min, true)

    assert_equal(1, sorted_players[3].id)
    assert_equal(0, sorted_players[2].id)
    assert_equal(3, sorted_players[1].id)
    assert_equal(2, sorted_players[0].id)

    assert_equal(@players[1].cost/22, sorted_players[3].value)
    assert_equal(@players[0].cost/10, sorted_players[2].value)
    assert_equal(FanDuelPlayer::INF_VALUE, sorted_players[1].value)
    assert_equal(@players[2].cost/-2, sorted_players[0].value)
  end

  test "override default sort for non-number" do
    sorted_players = FanDuelPlayer.sort(@players, :name, false)

    assert_equal(3, sorted_players[3].id)
    assert_equal(1, sorted_players[2].id)
    assert_equal(0, sorted_players[1].id)
    assert_equal(2, sorted_players[0].id)

    assert_equal(FanDuelPlayer::INF_VALUE, sorted_players[3].value)
    assert_equal(@players[1].cost/2, sorted_players[2].value)
    assert_equal(@players[0].cost/50, sorted_players[1].value)
    assert_equal(@players[2].cost/5, sorted_players[0].value)
  end

  test "sort and revalue" do
    sorted_players = FanDuelPlayer.sort(@players, :min)

    assert_equal(1, sorted_players[0].id)
    assert_equal(0, sorted_players[1].id)
    assert_equal(3, sorted_players[2].id)
    assert_equal(2, sorted_players[3].id)

    assert_equal(@players[1].cost/22, sorted_players[0].value)
    assert_equal(@players[0].cost/10, sorted_players[1].value)
    assert_equal(FanDuelPlayer::INF_VALUE, sorted_players[2].value)
    assert_equal(@players[2].cost/-2, sorted_players[3].value)
  end

  test "sort non-number column" do
    sorted_players = FanDuelPlayer.sort(@players, :name)

    assert_equal(3, sorted_players[0].id)
    assert_equal(1, sorted_players[1].id)
    assert_equal(0, sorted_players[2].id)
    assert_equal(2, sorted_players[3].id)

    assert_equal(FanDuelPlayer::INF_VALUE, sorted_players[0].value)
    assert_equal(@players[1].cost/2, sorted_players[1].value)
    assert_equal(@players[0].cost/50, sorted_players[2].value)
    assert_equal(@players[2].cost/5, sorted_players[3].value)
  end

  test "expp" do
    players = FanDuelPlayer.player_data({:league => "NFL"})

    pmanning_exp_median = ((23.82 + 28.62)/2).round(1)

    pmanning = (players.select {|p| p.id == 2625}).first
    ajgreen  = (players.select {|p| p.id == 2650}).first

    assert_equal(pmanning_exp_median,pmanning.med)
    assert_equal(11.6,ajgreen.med)
    assert_equal(30,pmanning.exp)
    assert_equal((pmanning_exp_median*1.295).round(1),pmanning.expp)
  end
end
