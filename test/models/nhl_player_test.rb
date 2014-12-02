require 'test_helper'

class NhlPlayerTest < ActiveSupport::TestCase
  test "unified_name_parser" do
    player = NhlPlayer.new()
    assert_equal("CPrice", player.unified_name("Carey Price"))
    assert_equal("CPrice", player.unified_name("Price, Carey"))
    assert_equal("MFleury", player.unified_name("Marc-Andre Fleury"))
    assert_equal("Fleury", player.unified_name("Fleury"))
  end

  test "expectation" do
    pos_player = NhlPlayer.new({:opp => "EDM", :game_data => [10]})
    neg_player = NhlPlayer.new({:opp => "CHI", :game_data => [10]})
    pos_goalie = NhlPlayer.new({:opp => "BUF", :position => "G", :game_data => [10]})
    neg_goalie = NhlPlayer.new({:opp => "TB", :position => "G", :game_data => [10]})

    assert_equal(17,  pos_player.exp)
    assert_equal((10 * 1.17),  pos_player.expp)
    assert_equal(-18,  neg_player.exp)
    assert_equal((10 * 0.82),  neg_player.expp)
    assert_equal(23, pos_goalie.exp)
    assert_equal((10 * 1.23), pos_goalie.expp)
    assert_equal(-20, neg_goalie.exp)
    assert_equal((10 * 0.8), neg_goalie.expp)
  end
end
