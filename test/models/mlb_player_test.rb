require 'test_helper'

class MlbPlayerTest < ActiveSupport::TestCase
  PLAYER_JSON        = "#{File.open("test/fixtures/fd_players.json").read()}"
  PLAYER_DETAIL_JSON = "#{File.open("test/fixtures/fd_player_detail.json").read()}"

  test "starting? override" do
    pitcher_probable_starting        = MlbPlayer.new({:fd_data => {"probable_pitcher"=>true,"starting_order"=>1,"position"=>"P"}})
    pitcher_notprobable_starting     = MlbPlayer.new({:fd_data => {"probable_pitcher"=>false,"starting_order"=>1,"position"=>"P"}})
    pitcher_probable_not_starting    = MlbPlayer.new({:fd_data => {"probable_pitcher"=>true,"starting_order"=>0,"position"=>"P"}})
    pitcher_notprobable_not_starting = MlbPlayer.new({:fd_data => {"probable_pitcher"=>false,"starting_order"=>0,"position"=>"P"}})
    pitcher_probable                 = MlbPlayer.new({:fd_data => {"probable_pitcher"=>true,"position"=>"P"}})
    pitcher_notprobable              = MlbPlayer.new({:fd_data => {"probable_pitcher"=>false,"position"=>"P"}})
    player_probable_starting         = MlbPlayer.new({:fd_data => {"probable_pitcher"=>true,"starting_order"=>1,"position"=>"1B"}})
    player_notprobable_starting      = MlbPlayer.new({:fd_data => {"probable_pitcher"=>false,"starting_order"=>1,"position"=>"1B"}})
    player_probable_not_starting     = MlbPlayer.new({:fd_data => {"probable_pitcher"=>true,"starting_order"=>0,"position"=>"1B"}})
    player_notprobable_not_starting  = MlbPlayer.new({:fd_data => {"probable_pitcher"=>false,"starting_order"=>0,"position"=>"1B"}})
    player_probable                  = MlbPlayer.new({:fd_data => {"probable_pitcher"=>true,"position"=>"1B"}})
    player_notprobable               = MlbPlayer.new({:fd_data => {"probable_pitcher"=>false,"position"=>"1B"}})

    assert_equal(true, pitcher_probable_starting.starting?)
    assert_equal(false, pitcher_notprobable_starting.starting?)
    assert_equal(true, pitcher_probable_not_starting.starting?)
    assert_equal(false, pitcher_notprobable_not_starting.starting?)
    assert_equal(true, pitcher_probable.starting?)
    assert_equal(false, pitcher_notprobable.starting?)
    assert_equal(true, player_probable_starting.starting?)
    assert_equal(true, player_notprobable_starting.starting?)
    assert_equal(false, player_probable_not_starting.starting?)
    assert_equal(false, player_notprobable_not_starting.starting?)
    assert_equal(nil, player_probable.starting?)
    assert_equal(nil, player_notprobable.starting?)
  end
end
