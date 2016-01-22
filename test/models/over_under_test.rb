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

  test "array mods" do
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
  end
end
