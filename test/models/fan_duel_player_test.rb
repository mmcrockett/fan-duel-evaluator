require 'test_helper'

class FanDuelPlayerTest < ActiveSupport::TestCase
  def setup
    @today       = Date.strptime("01/10/2010", "%m/%d/%Y")
    @cutoff_date = @today - 21
    @players = []
    @players << FanDuelPlayer.new({
      :id        => 0,
      :name      => "Max Avg",
      :position  => "X",
      :average   => 50,
      :cost      => 100,
      :game_data => [{"fpoints" => 10}, {"fpoints" => 30}, {"fpoints" => 20}, {"fpoints" => 40}],
      :game_log_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 1,
      :name      => "High Min",
      :position  => "X",
      :average   => 2,
      :cost      => 100,
      :game_data => [{"fpoints" => 22}, {"fpoints" => 22}, {"fpoints" => 22}, {"fpoints" => 22}],
      :game_log_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 2,
      :name      => "Z",
      :position  => "X",
      :average   => 5,
      :cost      => 100,
      :game_data => [{"fpoints" => 30}, {"fpoints" => 28}, {"fpoints" => 25}, {"fpoints" => -2}],
      :game_log_loaded => true})
    @players << FanDuelPlayer.new({
      :id        => 3,
      :name      => "All Zero",
      :position  => "X",
      :average   => 0,
      :cost      => 100,
      :game_data => [{"fpoints" => 0}, {"fpoints" => 0}, {"fpoints" => 0}, {"fpoints" => 0}],
      :game_log_loaded => true})
  end

  test "median" do
    player = FanDuelPlayer.new({
      :game_data => [{"fpoints" => 0}, {"fpoints" => 0}, {"fpoints" => 0}, {"fpoints" => 40}],
      :game_log_loaded => true})

    assert_equal(0, player.med)
    #assert_equal(40, player.mednz)
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

  test "player detail" do
    past_cutoff_td = "<td>12/13</td><td>@MIN</td><td>20</td><td>8.7</td>"
    last_year_td   = "<td>12/21</td><td>@MIN</td><td>15</td><td>7.7</td>"
    this_year_td   = "<td>01/05</td><td>@MIN</td><td>10</td><td>6.7</td>"
    past_cutoff_data = FanDuelPlayer.parse_player_detail(Nokogiri::HTML(past_cutoff_td).css('td'), @cutoff_date, @today)
    last_year_data   = FanDuelPlayer.parse_player_detail(Nokogiri::HTML(last_year_td).css('td'), @cutoff_date, @today)
    this_year_data   = FanDuelPlayer.parse_player_detail(Nokogiri::HTML(this_year_td).css('td'), @cutoff_date, @today)

    assert_nil(past_cutoff_data)
    assert_equal(Date.strptime("12/21/2009", "%m/%d/%Y"), last_year_data[:date])
    assert_equal(15, last_year_data[:minutes])
    assert_equal(7.7, last_year_data[:fpoints])
    assert_equal(Date.strptime("01/05/2010", "%m/%d/%Y"), this_year_data[:date])
    assert_equal(10, this_year_data[:minutes])
    assert_equal(6.7, this_year_data[:fpoints])

  end

  test "nil game stats" do
    no_points_td  = "<td>01/05</td><td>@MIN</td><td>10</td><td>0</td>"
    no_minutes_td = "<td>01/05</td><td>@MIN</td><td>0</td><td>6.7</td>"
    no_play_td    = "<td>01/05</td><td>@MIN</td><td>0</td><td>0</td>"

    assert_not_nil(FanDuelPlayer.parse_player_detail(Nokogiri::HTML(no_points_td).css('td'), @cutoff_date, @today))
    assert_not_nil(FanDuelPlayer.parse_player_detail(Nokogiri::HTML(no_minutes_td).css('td'), @cutoff_date, @today))
    assert_nil(FanDuelPlayer.parse_player_detail(Nokogiri::HTML(no_play_td).css('td'), @cutoff_date, @today))
  end

  test "player details" do
    table = <<-EOF
      <tr>
        <td>01/05</td><td>@MIN</td><td>10</td><td>6.7</td>
      </tr>
      <tr>
        <td>12/25</td><td>@MIN</td><td>17</td><td>7.2</td>
      </tr>
      <tr>
        <td>12/21</td><td>@MIN</td><td>15</td><td>7.7</td>
      </tr>
      <tr>
        <td>12/13</td><td>@MIN</td><td>20</td><td>8.7</td>
      </tr>
    EOF
    data = FanDuelPlayer.parse_player_details(Nokogiri::HTML(table), 2, @cutoff_date, @today)

    assert_equal(2, data.size)
    assert_equal(Date.strptime("01/05/2010", "%m/%d/%Y"), data[0][:date])
    assert_equal(10, data[0][:minutes])
    assert_equal(6.7, data[0][:fpoints])
    assert_equal(Date.strptime("12/25/2009", "%m/%d/%Y"), data[1][:date])
    assert_equal(17, data[1][:minutes])
    assert_equal(7.2, data[1][:fpoints])
  end
end
