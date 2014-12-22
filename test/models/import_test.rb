require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  test "parse type" do
    assert_equal("CBB", Import.parse_type("						FD.playerpicker.competitionName = 'CBB'.toLowerCase();"))
    assert_nil(Import.parse_type("						FD.playerpicker.competitionNme = 'CBB'.toLowerCase();"))
  end

  test "parse fd game id" do
    assert_equal("11276", Import.parse_fd_game_id("			FD.playerpicker.gameId = 11276;"))
    assert_nil(Import.parse_fd_game_id("			FDplayerpicker.gameId = 11276;"))
  end

  test "parse data" do
    assert_equal('{"24186":["G","Tyrone Wallace","90582","719","1000","8800",37.5,"11",false,0,"","recent",""]}', Import.parse_data('			FD.playerpicker.allPlayersFullData = {"24186":["G","Tyrone Wallace","90582","719","1000","8800",37.5,"11",false,0,"","recent",""]};'))
    assert_nil(Import.parse_data('			FD.playerpickerallPlayersFullData = {"24186":["G","Tyrone Wallace","90582","719","1000","8800",37.5,"11",false,0,"","recent",""]};'))
  end

  test "parse teams" do
    teams = Import.parse_teams('FD.playerpicker.teamIdToFixtureCompactString = {"1104":"KANS@<b>TEMPL</b>","735":"<b>KANS</b>@TEMPL","742":"PROV@<b>MIAMI</b>","761":"<b>PROV</b>@MIAMI","719":"WISCN@<b>CAL</b>","785":"<b>WISCN</b>@CAL","782":"TLANE@<b>WASH</b>","956":"<b>TLANE</b>@WASH"};')

    assert_equal("TEMPL", teams["1104"])
    assert_equal("KANS", teams["735"])

    assert_nil(Import.parse_teams('FD.layerpicker.teamIdToFixtureCompactString = {"1104":"KANS@<b>TEMPL</b>","735":"<b>KANS</b>@TEMPL","742":"PROV@<b>MIAMI</b>","761":"<b>PROV</b>@MIAMI","719":"WISCN@<b>CAL</b>","785":"<b>WISCN</b>@CAL","782":"TLANE@<b>WASH</b>","956":"<b>TLANE</b>@WASH"};'))
  end

  test "parse kv pair" do
    assert_equal("128", Import.value("something = 128;\n"))
    assert_equal('{"24186":["G","Tyrone Wallace","90582","719","1000","8800",37.5,"11",false,0,"","recent",""]}', Import.value('			FD.playerpicker.allPlayersFullData = {"24186":["G","Tyrone Wallace","90582","719","1000","8800",37.5,"11",false,0,"","recent",""]};'))
  end

  test "url import" do
    return
    params = Import.parse("https://www.fanduel.com/e/Game/11276?tableId=8952557&fromLobby=true")

    assert_equal("CBB", params[:league])
    assert_equal("11276", params[:fd_game_id])
    assert_equal("TEMPL",params[:teams]["1104"])
  end
end
