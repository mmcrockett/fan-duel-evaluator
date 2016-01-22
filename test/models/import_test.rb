require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  PLAYER_JSON        = "#{File.open("test/fixtures/fd_players.json").read()}"

  test "convert teams" do
    data = JSON.parse(PLAYER_JSON)
    teams = Import.convert_teams(data)

    teams.keys.each do |k|
      assert_equal(MlbPlayer::TEAMS_BY_FD_ID[k], teams[k])
    end
  end

  test "url import" do
    return true
    params = Import.parse("https://www.fanduel.com/games/12564/contests/12564-13442827/enter")

    assert_equal("CBB", params[:league])
    assert_equal("11276", params[:fd_contest_id])
    assert_equal("TEMPL",params[:teams]["1104"])
  end
end
