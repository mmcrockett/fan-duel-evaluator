require 'test_helper'

class OverUnderTest < ActiveSupport::TestCase
  test "moneyline to odds" do
    assert_equal(0.6, OverUnder.moneyline_to_decimal(-150))
    assert_equal(0.4, OverUnder.moneyline_to_decimal(150))
  end

  test "parse spread text" do
    assert_equal(5.5, OverUnder.parse_spread("5.5"))
    assert_equal((12*0.4).round(1), OverUnder.parse_spread("6u50"))
    assert_equal((12*0.6).round(1), OverUnder.parse_spread("6o50"))
    assert_equal(0.0, OverUnder.parse_spread(nil))
  end

  test "home and away calculation" do
    import = Import.find(11)
    expected_scores = OverUnder.get_expected_scores(import)
    assert_equal(654, expected_scores[:scores].sum)
    assert_equal("STL", expected_scores["DEN"][:opp])
    assert_equal("DEN", expected_scores["STL"][:opp])
    assert_equal(30.25, expected_scores["DEN"][:score])
    assert_equal(20.75, expected_scores["STL"][:score])
  end

  test "calculate boost" do
    scores = [10,6,8,12]
    mean   = scores.mean
    median = scores.median

    assert_equal(9, mean)
    assert_equal(4, [4,2,8].median)
    assert_equal(6, [4,2,8,10].median)
    assert_equal(0, [].median)
    assert_equal(4, [4].median)
    assert_equal(6, [4,8].median)
    assert_equal(0, ["h","i"].median)
    assert_equal(0, ["h","i"].median)

    assert_equal(0,    OverUnder.multiplier(0, scores))
    assert_equal(0,    OverUnder.multiplier(9, scores))
    assert_equal(1,    OverUnder.multiplier(18, scores))
    assert_equal(0.5,  OverUnder.multiplier(13.5, scores))
    assert_equal(1.0/3.0, OverUnder.multiplier(12, scores))
    assert_equal(-0.5,  OverUnder.multiplier(4.5, scores))

    assert_equal(0,   OverUnder.calculate_boost(0, scores))
    assert_equal(0,   OverUnder.calculate_boost(9, scores))
    assert_equal(100, OverUnder.calculate_boost(18, scores))
    assert_equal(50,  OverUnder.calculate_boost(13.5, scores))
    assert_equal(33,  OverUnder.calculate_boost(12, scores))
    assert_equal(-50,  OverUnder.calculate_boost(4.5, scores))

    assert_equal(1,     OverUnder.calculate_boost_multiplier(0, scores))
    assert_equal(1,     OverUnder.calculate_boost_multiplier(9, scores))
    assert_equal(2,     OverUnder.calculate_boost_multiplier(18, scores))
    assert_equal(1.5,   OverUnder.calculate_boost_multiplier(13.5, scores))
    assert_equal(1.333, OverUnder.calculate_boost_multiplier(12, scores))
    assert_equal(0.5,   OverUnder.calculate_boost_multiplier(4.5, scores))
  end
end
