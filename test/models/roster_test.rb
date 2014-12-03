require 'test_helper'

class TestPlayer < FanDuelPlayer
  POSITIONS  = ["X","X"]
  BUDGET     = 100
end

class RosterTest < ActiveSupport::TestCase
  def setup
    @players = []
    @players << TestPlayer.new({
      :id        => 0,
      :position  => "X",
      :cost      => 5,
      :game_data => [0,10,-2]
    })
    @players << TestPlayer.new({
      :id        => 1,
      :position  => "X",
      :cost      => 5,
      :game_data => [2,1,9]
    })
    @players << TestPlayer.new({
      :id        => 2,
      :position  => "X",
      :cost      => 5,
      :game_data => [6,4,0]
    })
    @players << TestPlayer.new({
      :id        => 3,
      :position  => "X",
      :cost      => 5,
      :game_data => [4,4,4]
    })
  end

  test "unique" do
    best_rosters = Roster.get_best_rosters(@players, TestPlayer::POSITIONS, TestPlayer::BUDGET, [:med, :min])

    assert_equal([2,3], best_rosters[:med].player_ids.sort)
    assert_equal([1,3], best_rosters[:min].player_ids.sort)

    best_rosters = Roster.get_best_rosters(@players, TestPlayer::POSITIONS, TestPlayer::BUDGET, [:med, :min], true)

    assert_equal([2,3], best_rosters[:med].player_ids.sort)
    assert_equal([0,1], best_rosters[:min].player_ids.sort)
  end

  test "best rosters" do
    @players[0].cost = 70
    @players[1].cost = 50
    @players[2].cost = 50
    @players[3].cost = 20

    best_rosters = Roster.get_best_rosters(@players, TestPlayer::POSITIONS, TestPlayer::BUDGET, [:max, :min, :med])

    max_roster = nil
    med_roster = nil
    min_roster = nil

    best_rosters.each_pair do |k, roster|
      if (true == "#{k}".include?("max"))
        max_roster = Roster.best(max_roster, roster)
      elsif (true == "#{k}".include?("med"))
        med_roster = Roster.best(med_roster, roster)
      elsif (true == "#{k}".include?("min"))
        min_roster = Roster.best(min_roster, roster)
      else
        raise "!ERROR: Unknown key '#{k}'."
      end
    end

    assert_equal([1,2], max_roster.player_ids.sort)
    assert_equal([2,3], med_roster.player_ids.sort)
    assert_equal([1,3], min_roster.player_ids.sort)
  end

  test "absolute best rosters" do
    best_rosters = Roster.get_best_rosters(@players, TestPlayer::POSITIONS, TestPlayer::BUDGET, [:max, :min, :med])

    max_roster = nil
    med_roster = nil
    min_roster = nil

    best_rosters.each_pair do |k, roster|
      if (true == "#{k}".include?("max"))
        max_roster = Roster.best(max_roster, roster)
      elsif (true == "#{k}".include?("med"))
        med_roster = Roster.best(med_roster, roster)
      elsif (true == "#{k}".include?("min"))
        min_roster = Roster.best(min_roster, roster)
      else
        raise "!ERROR: Unknown key '#{k}'."
      end
    end

    assert_equal(true, max_roster.is_a?(SimpleRoster))
    assert_equal([0,1], max_roster.player_ids.sort)
    assert_equal([2,3], med_roster.player_ids.sort)
    assert_equal([1,3], min_roster.player_ids.sort)
  end

  test "best roster" do
    incomplete_roster0 = SimpleRoster.new(TestPlayer::BUDGET, TestPlayer::POSITIONS.size, :med)
    incomplete_roster1 = incomplete_roster0.dup
    complete_roster0   = incomplete_roster0.dup
    complete_roster1   = incomplete_roster0.dup
    nil_roster0 = nil
    nil_roster1 = nil

    complete_roster0 << @players[0]
    complete_roster0 << @players[1]
    complete_roster1 << @players[2]
    complete_roster1 << @players[3]

    assert_equal(complete_roster1, Roster.best(complete_roster1, complete_roster0))
    assert_equal(complete_roster1, Roster.best(complete_roster0, complete_roster1))
    assert_equal(complete_roster1, Roster.best(incomplete_roster0, complete_roster1))
    assert_equal(complete_roster0, Roster.best(complete_roster0, incomplete_roster1))
    assert_equal(complete_roster1, Roster.best(nil_roster0, complete_roster1))
    assert_equal(complete_roster0, Roster.best(complete_roster0, nil_roster1))
    assert_equal(nil, Roster.best(incomplete_roster0, incomplete_roster1))
    assert_equal(nil, Roster.best(incomplete_roster0, nil_roster1))
    assert_equal(nil, Roster.best(nil_roster0, incomplete_roster1))
    assert_equal(nil, Roster.best(nil_roster0, nil_roster1))
  end

  test "post optimize" do
    player_finder  = PlayerFinder.new(FanDuelPlayer.sort(@players, :med))
    sroster        = SimpleRoster.new(TestPlayer::BUDGET, TestPlayer::POSITIONS.size, :med)
    sroster << @players[1] << @players[0]
    best_roster = sroster
    optimize = true

    assert_equal([@players[1], @players[0]], sroster.players)

    while (true == optimize)
      new_best = Roster.post_optimize(best_roster, player_finder, :med)

      if (new_best == best_roster)
        optimize = false
      else
        best_roster = new_best
      end
    end

    assert_not_equal(new_best, sroster)
    assert_equal([2,3], new_best.player_ids.sort)
    assert_equal(new_best, Roster.post_optimize(new_best, player_finder, :med))
  end

  test "finishes" do
    @players[0].cost = 70
    @players[1].cost = 70
    @players[2].cost = 70
    @players[3].cost = 70

    best_rosters = Roster.get_best_rosters(@players, TestPlayer::POSITIONS, TestPlayer::BUDGET, [:max, :min, :med])

    max_roster = best_rosters[:max]
    med_roster = best_rosters[:med]
    min_roster = best_rosters[:min]

    assert_equal(false, max_roster.is_a?(Array))
    assert_equal(false, med_roster.is_a?(Array))
    assert_equal(false, min_roster.is_a?(Array))
  end
end
