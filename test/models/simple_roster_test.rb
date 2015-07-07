require 'test_helper'

class SimpleRosterTest < ActiveSupport::TestCase
  def setup
    players = FanDuelPlayer.player_data({:league => "NFL"})
    @sorted_players  = FanDuelPlayer.sort(players, :fppg)
    @max_roster_size = @sorted_players.first.class::POSITIONS.size
  end

  test "non_default_point_column" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size, :min)
    sroster << @sorted_players.first
    assert_equal(@sorted_players.first.min,sroster.points)
  end

  test "max_cost" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)
    @sorted_players.first.stubs(:cost).returns(@sorted_players.first.class::BUDGET)
    sroster << @sorted_players.first
    assert_equal(@sorted_players.first.cost, @sorted_players.first.class::BUDGET)
  end

  test "add_player" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)
    sroster << @sorted_players.first
    assert_equal(@sorted_players.first.cost,sroster.cost)
    assert_equal(@sorted_players.first.class::BUDGET - @sorted_players.first.cost,sroster.remaining_budget)
    assert_equal(((@sorted_players.first.class::BUDGET - @sorted_players.first.cost)/(@max_roster_size - 1)).to_i,sroster.remaining_avg_budget)
    assert_equal(@sorted_players.first.fppg,sroster.points)
    assert_equal([@sorted_players.first],sroster.players)
  end

  test "delete_player" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)
    sroster << @sorted_players.first
    points = sroster.points
    cost   = sroster.cost
    rbud   = sroster.remaining_budget
    rabud  = sroster.remaining_avg_budget
    sroster << @sorted_players[1]

    assert_not_equal(cost,sroster.cost)
    assert_not_equal(rbud,sroster.remaining_budget)
    assert_not_equal(rabud,sroster.remaining_avg_budget)
    assert_not_equal(points,sroster.points)
    assert_not_equal([@sorted_players.first],sroster.players)
    assert_not_equal([@sorted_players.first.id],sroster.player_ids)
    sroster.delete(@sorted_players[1])
    assert_equal(cost,sroster.cost)
    assert_equal(rbud,sroster.remaining_budget)
    assert_equal(rabud,sroster.remaining_avg_budget)
    assert_equal(points,sroster.points)
    assert_equal([@sorted_players.first],sroster.players)
    assert_equal([@sorted_players.first.id],sroster.player_ids)
  end

  test "player ids" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)
    player_ids = []

    @max_roster_size.times do |i|
      sroster << @sorted_players[-i]
      player_ids << @sorted_players[-i].id
    end

    assert_equal(player_ids, sroster.player_ids)
  end

  test "dup" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)

    @max_roster_size.times do |i|
      sroster << @sorted_players[-i]
    end

    droster = sroster.dup

    assert_equal(sroster.cost, droster.cost)
    assert_equal(sroster.points, droster.points)
    assert_equal(sroster.player_ids, droster.player_ids)
    assert_equal(sroster.pcolumn, droster.pcolumn)
    assert_equal(sroster.budget, droster.budget)

    players = droster.players.dup

    players.each do |p|
      droster.delete(p)
    end

    assert_equal(0, droster.cost)
    assert_equal(0, droster.points)
    assert_equal([], droster.player_ids)
    assert_equal(sroster.pcolumn, droster.pcolumn)
    assert_equal(sroster.budget, droster.budget)

    assert_not_equal(0, sroster.cost)
    assert_not_equal(0, sroster.points)
    assert_not_equal([], sroster.player_ids)
    assert_equal(sroster.pcolumn, droster.pcolumn)
    assert_equal(sroster.budget, droster.budget)
  end

  test "complete?" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)

    @max_roster_size.times do |i|
      assert_equal(false, sroster.complete?)
      sroster << @sorted_players[-i]
    end

    assert_equal(true, sroster.complete?)
  end

  test "fail_too_many" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)

    assert_raise SimpleRosterSizeException do |x|
      10.times do |i|
        sroster << @sorted_players[-i]
      end
    end
  end

  test "fail_too_expensive" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)

    assert_raise SimpleRosterBudgetException do |x|
      9.times do |i|
        sroster << @sorted_players[i]
      end
    end
  end

  test "fail_duplicate" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)

    assert_raise SimpleRosterDuplicateException do |x|
      sroster << @sorted_players.first
      sroster << @sorted_players.first
    end
  end

  test "fail_delete_player" do
    sroster = SimpleRoster.new(@sorted_players.first.class::BUDGET, @max_roster_size)

    assert_raise SimpleRosterNotFoundException do |x|
      sroster << @sorted_players[0]
      sroster << @sorted_players[1]
      sroster.delete(@sorted_players[2])
    end
  end
end
