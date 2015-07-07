require 'test_helper'

class FanDuelPlayerTest < ActiveSupport::TestCase
  PLAYER_JSON        = "#{File.open("test/fixtures/fd_players.json").read()}"
  PLAYER_DETAIL_JSON = "#{File.open("test/fixtures/fd_player_detail.json").read()}"

  def setup
    @today       = Date.strptime("01/10/2010", "%m/%d/%Y")
    @cutoff_date = @today - 21
    @players = []
    @players << FanDuelPlayer.new({
      :id        => 0,
      :fd_data   => {
        "salary"=>100,
        "injured"=>false,
        "first_name"=>"Max",
        "last_name"=>"Avg",
        "probable_pitcher"=>false,
        "played"=>16,
        "position"=>"X",
        "fppg"=>50,
        "news"=>{"latest"=>"2015-06-27T02:34:44Z"},
        "id"=>"13627"
      },
      :game_data => [
        {"Date" => "01\/05","Opp" => "v PIT","IP" => "9.0","H" => "0","BB" => "0","K" => "10","ERA" => "1.76","W" => "1","FP" => "10"},
        {"Date" => "12\/25","Opp" => "@MIL","IP" => "9.0","H" => "1","BB" => "1","K" => "16","ERA" => "1.93","W" => "1","FP" => "30"},
        {"Date" => "12\/21","Opp" => "@NYY","IP" => "6.2","H" => "8","BB" => "1","K" => "7","ERA" => "2.13","W" => "0","FP" => "20"},
        {"Date" => "12\/13","Opp" => "@NYM","IP" => "7.0","H" => "5","BB" => "1","K" => "10","ERA" => "1.26","W" => "0","FP" => "40"}],
      :game_data_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 1,
      :fd_data   => {
        "salary"=>100,
        "injured"=>false,
        "first_name"=>"High",
        "last_name"=>"Min",
        "probable_pitcher"=>false,
        "played"=>16,
        "position"=>"X",
        "fppg"=>2,
        "news"=>{"latest"=>"2015-06-27T02:34:44Z"},
        "id"=>"13627"
      },
      :game_data => [
        {"Date" => "01\/05","Opp" => "v PIT","IP" => "9.0","H" => "0","BB" => "0","K" => "10","ERA" => "1.76","W" => "1","FP" => "22"},
        {"Date" => "12\/25","Opp" => "@MIL","IP" => "9.0","H" => "1","BB" => "1","K" => "16","ERA" => "1.93","W" => "1","FP" => "22"},
        {"Date" => "12\/21","Opp" => "@NYY","IP" => "6.2","H" => "8","BB" => "1","K" => "7","ERA" => "2.13","W" => "0","FP" => "22"},
        {"Date" => "12\/13","Opp" => "@NYM","IP" => "7.0","H" => "5","BB" => "1","K" => "10","ERA" => "1.26","W" => "0","FP" => "22"}],
      :game_data_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 2,
      :fd_data   => {
        "salary"=>100,
        "injured"=>false,
        "first_name"=>"Z",
        "last_name"=>"Z",
        "probable_pitcher"=>false,
        "played"=>16,
        "position"=>"X",
        "fppg"=>5,
        "news"=>{"latest"=>"2015-06-27T02:34:44Z"},
        "id"=>"13627"
      },
      :game_data => [
        {"Date" => "01\/05","Opp" => "v PIT","IP" => "9.0","H" => "0","BB" => "0","K" => "10","ERA" => "1.76","W" => "1","FP" => "30"},
        {"Date" => "12\/25","Opp" => "@MIL","IP" => "9.0","H" => "1","BB" => "1","K" => "16","ERA" => "1.93","W" => "1","FP" => "28"},
        {"Date" => "12\/21","Opp" => "@NYY","IP" => "6.2","H" => "8","BB" => "1","K" => "7","ERA" => "2.13","W" => "0","FP" => "25"},
        {"Date" => "12\/13","Opp" => "@NYM","IP" => "7.0","H" => "5","BB" => "1","K" => "10","ERA" => "1.26","W" => "0","FP" => "-2"}],
      :game_data_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 3,
      :fd_data   => {
        "salary"=>100,
        "injured"=>false,
        "first_name"=>"All",
        "last_name"=>"Zero",
        "probable_pitcher"=>false,
        "played"=>16,
        "position"=>"X",
        "fppg"=>0,
        "news"=>{"latest"=>"2015-06-27T02:34:44Z"},
        "id"=>"13627"
      },
      :game_data => [
        {"Date" => "01\/05","Opp" => "v PIT","IP" => "9.0","H" => "0","BB" => "0","K" => "10","ERA" => "1.76","W" => "1","FP" => "0"},
        {"Date" => "12\/25","Opp" => "@MIL","IP" => "9.0","H" => "1","BB" => "1","K" => "16","ERA" => "1.93","W" => "1","FP" => "0"},
        {"Date" => "12\/21","Opp" => "@NYY","IP" => "6.2","H" => "8","BB" => "1","K" => "7","ERA" => "2.13","W" => "0","FP" => "0"},
        {"Date" => "12\/13","Opp" => "@NYM","IP" => "7.0","H" => "5","BB" => "1","K" => "10","ERA" => "1.26","W" => "0","FP" => "0"}],
      :game_data_loaded => true})
  end

  test "basic player functionality" do
    FanDuelPlayer.player_data({:league => "BAD"}) # Clear overunderset
    rawplayer0  = FanDuelPlayer.find(1998)
    assert_not_nil(rawplayer0)
    assert_equal("Paul Goldschmidt", rawplayer0.name)
    assert_equal("Paul", rawplayer0.first_name)
    assert_equal("Goldschmidt", rawplayer0.last_name)
    assert_equal(5400, rawplayer0.cost)
    assert_equal(false, rawplayer0.disabled?)
    assert_equal("1B", rawplayer0.pos)
    assert_equal(4.39, rawplayer0.fppg)
    assert_equal(616, rawplayer0.team_id)
    assert_equal(0, rawplayer0.exp) # Because over unders aren't loaded
  end

  test "parse json" do
    data = JSON.parse(PLAYER_JSON)
    FanDuelPlayer.parse(data["players"], Import.new({:id => 999, :league => 'MLB'}))
  end

  test "loading from json" do
    players_json = JSON.parse(PLAYER_JSON)
    player = FanDuelPlayer.player(players_json["players"][0])

    assert_equal(players_json["players"][0], player.fd_data)
  end

  test "player median" do
    player = FanDuelPlayer.new({
      :game_data => [
        {"Date" => "01\/05","Opp" => "v PIT","IP" => "9.0","H" => "0","BB" => "0","K" => "10","ERA" => "1.76","W" => "1","FP" => "0"},
        {"Date" => "12\/25","Opp" => "@MIL","IP" => "9.0","H" => "1","BB" => "1","K" => "16","ERA" => "1.93","W" => "1","FP" => "0"},
        {"Date" => "12\/21","Opp" => "@NYY","IP" => "6.2","H" => "8","BB" => "1","K" => "7","ERA" => "2.13","W" => "0","FP" => "0"},
        {"Date" => "12\/13","Opp" => "@NYM","IP" => "7.0","H" => "5","BB" => "1","K" => "10","ERA" => "1.26","W" => "0","FP" => "40"}],
      :game_data_loaded => true})

    assert_equal(0, player.med)
  end

  test "default everything" do
    sorted_players = FanDuelPlayer.sort(@players, :fppg)

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

  test "game data" do
    FanDuelPlayer.any_instance.stubs(:team_name).returns("DEN")
    players = FanDuelPlayer.player_data({:league => "MLB"})

    exp_median = ((23.82 + 28.62)/2).round(1)

    player0 = (players.select {|p| p.id == 1998}).first
    player1 = (players.select {|p| p.id == 1999}).first

    assert_equal(23.44,player0.min)
    assert_equal(exp_median,player0.med)
    assert_equal(31.6,player0.max)
    assert_equal("STL",player0.opp)
    assert_equal(11.6,player1.med)
  end

  test "expectations" do
    FanDuelPlayer.any_instance.stubs(:team_name).returns("DEN")
    players = FanDuelPlayer.player_data({:league => "MLB"})

    exp_median = ((23.82 + 28.62)/2).round(1)
    exp_mult   = 1.295

    player0 = (players.select {|p| p.id == 1998}).first

    assert_equal(30,player0.team_exp(:percentage))
    assert_equal(30,player0.team_exp)
    assert_equal(0.295,player0.team_exp(:raw).round(3))
    assert_equal(exp_mult,player0.team_exp(:adjustment).round(3))

    assert_equal((4.39*exp_mult).round(1),player0.exp)
    assert_equal((exp_median*exp_mult).round(1),player0.exp(:med))
  end

  test "player detail" do
    past_cutoff = JSON.parse('{"Date":"12\/13"}')
    last_year   = JSON.parse('{"Date":"12\/21"}')
    this_year   = JSON.parse('{"Date":"01\/05"}')
    past_cutoff_data = FanDuelPlayer.parse_player_detail(past_cutoff, @cutoff_date, @today)
    last_year_data   = FanDuelPlayer.parse_player_detail(last_year, @cutoff_date, @today)
    this_year_data   = FanDuelPlayer.parse_player_detail(this_year, @cutoff_date, @today)

    assert_nil(past_cutoff_data)
    assert_equal(Date.strptime("12/21/2009", "%m/%d/%Y"), last_year_data[:date])
    assert_equal(last_year, last_year_data[:data])
    assert_equal(Date.strptime("01/05/2010", "%m/%d/%Y"), this_year_data[:date])
    assert_equal(this_year, this_year_data[:data])
  end

  test "player_news" do
    player_detail = JSON.parse(PLAYER_DETAIL_JSON)
    data = FanDuelPlayer.parse_player_news(player_detail)

    assert_equal("Scherzer threw his first career no-hitter Saturday against the Pirates, striking out 10 without issuing a walk.", data)

    assert_raise RuntimeError do |x|
      data = FanDuelPlayer.parse_player_news(player_detail["news"])
    end

    assert_raise NoMethodError do |x|
      data = FanDuelPlayer.parse_player_news(nil)
    end
  end

  test "player details" do
    player_detail = JSON.parse(PLAYER_DETAIL_JSON)
    data = FanDuelPlayer.parse_player_details(player_detail["player"]["gamestats"], 2, @cutoff_date, @today)

    assert_equal(2, data.size)
    assert_equal(Date.strptime("01/05/2010", "%m/%d/%Y"), data[0][:date])
    assert_equal(player_detail["player"]["gamestats"][0], data[0][:data])
    assert_equal(Date.strptime("12/25/2009", "%m/%d/%Y"), data[1][:date])
    assert_equal(player_detail["player"]["gamestats"][1], data[1][:data])
  end

  test "extract latest game" do
    dec24 = Date.strptime("2014-12-24", "%Y-%m-%d")
    dec25 = Date.strptime("2014-12-25", "%Y-%m-%d")
    dec26 = Date.strptime("2014-12-26", "%Y-%m-%d")

    playerA= FanDuelPlayer.new({
      :fd_data   => {"team" => {"_members" => ["TeamName"]}},
      :game_data => [{"date" => dec26}],
      :game_data_loaded => false})
    playerB= FanDuelPlayer.new({
      :fd_data   => {"team" => {"_members" => ["TeamName"]}},
      :game_data => [],
      :game_data_loaded => true})
    playerC= FanDuelPlayer.new({
      :fd_data   => {"team" => {"_members" => ["TeamName"]}},
      :game_data => [{"date" => dec24}],
      :game_data_loaded => true})
    playerD= FanDuelPlayer.new({
      :fd_data   => {"team" => {"_members" => ["TeamName"]}},
      :game_data => [{"date" => dec25}],
      :game_data_loaded => true})
    playerE= FanDuelPlayer.new({
      :fd_data   => {"team" => {"_members" => ["TeamName"]}},
      :game_data => [{"date" => dec24}],
      :game_data_loaded => true})
    playerF= FanDuelPlayer.new({
      :fd_data   => {"team" => {"_members" => ["TeamName"]}},
      :game_data => [{"date" => dec26}],
      :game_data_loaded => true})
    playerG= FanDuelPlayer.new({
      :fd_data   => {"team" => {"_members" => ["OtherTeamName"]}},
      :game_data => [{"date" => dec24}],
      :game_data_loaded => true})

    playerA.stubs(:team_name).returns("TeamName")
    playerB.stubs(:team_name).returns("TeamName")
    playerC.stubs(:team_name).returns("TeamName")
    playerD.stubs(:team_name).returns("TeamName")
    playerE.stubs(:team_name).returns("TeamName")
    playerF.stubs(:team_name).returns("TeamName")
    playerG.stubs(:team_name).returns("OtherTeamName")

    assert_equal(nil, FanDuelPlayer.extract_latest_game(playerA)["TeamName"])
    assert_equal(nil, FanDuelPlayer.extract_latest_game(playerB)["TeamName"])
    assert_equal(dec24, FanDuelPlayer.extract_latest_game(playerC)["TeamName"])
    assert_equal(dec25, FanDuelPlayer.extract_latest_game(playerD)["TeamName"])
    assert_equal(dec25, FanDuelPlayer.extract_latest_game(playerE)["TeamName"])
    assert_equal(dec26, FanDuelPlayer.extract_latest_game(playerF)["TeamName"])
    assert_equal(dec26, FanDuelPlayer.extract_latest_game(playerG)["TeamName"])
    assert_equal(dec24, FanDuelPlayer.extract_latest_game(playerG)["OtherTeamName"])
  end
end
