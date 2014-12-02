require 'test_helper'

class NhlStandingsTest < ActiveSupport::TestCase
  test "import" do
    #NhlStandings.load(0)
  end

  test "data" do
    NhlStandings.data(-1)
    edm_allowed_avg = (82.0/24.0)
    edm_scored_avg  = (54.0/24.0)

    assert_equal(712, NhlStandings.games)
    assert_equal((1946.0/712.0).round(2), NhlStandings.goals_allowed_avg.round(2))
    assert_equal(NhlStandings.goals_allowed_avg.round(2), NhlStandings.goals_scored_avg.round(2))
    assert_equal(edm_allowed_avg.round(2), NhlStandings.goals_allowed_avg("EDM").round(2))
    assert_equal(edm_scored_avg.round(2), NhlStandings.goals_scored_avg("EDM").round(2))
    assert_equal(-1.18, NhlStandings.goals_scored_exp("EDM").round(2))
    assert_equal(0.12, NhlStandings.goals_scored_exp("NSH").round(2))
    assert_equal(1.67, NhlStandings.goals_allowed_exp("EDM").round(2))
    assert_equal(-0.06, NhlStandings.goals_allowed_exp("NYI").round(2))
    assert_equal(1.87, NhlStandings.goals_allowed_exp("DAL").round(2))
    assert_equal(1.97, NhlStandings.goals_scored_exp("TB").round(2))
    assert_equal(-0.17, NhlStandings.goals_allowed_exp("TB").round(2))

    NhlPlayer::TEAMS_BY_FD_ID.values.each do |team_name|
      NhlStandings.games(team_name)
    end

    assert_raise NhlStandingsException do |e|
      NhlStandings.games("BogusTeam")
    end
  end
end
