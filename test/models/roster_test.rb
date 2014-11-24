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

  test "best rosters" do
    @players[0].cost = 70
    @players[1].cost = 50
    @players[2].cost = 50
    @players[3].cost = 20

    best_rosters = Roster.get_best_rosters(@players, TestPlayer::POSITIONS, TestPlayer::BUDGET)

    max_roster = best_rosters[:max]
    #med_roster = best_rosters[:med]
    #min_roster = best_rosters[:min]

    assert_equal([1,2], max_roster.player_ids)
    #assert_equal([2,3], med_roster.player_ids)
    #assert_equal([1,3], min_roster.player_ids)
  end

  test "absolute best rosters" do
    return
    best_rosters = Roster.get_best_rosters(@players, TestPlayer::POSITIONS, TestPlayer::BUDGET)

    max_roster = best_rosters[:max]
    med_roster = best_rosters[:med]
    min_roster = best_rosters[:min]

    assert_equal([0,1], max_roster.player_ids)
    assert_equal([2,3], med_roster.player_ids)
    assert_equal([1,3], min_roster.player_ids)
  end
end
