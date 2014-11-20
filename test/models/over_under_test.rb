require 'test_helper'

class OverUnderTest < ActiveSupport::TestCase
  test "moneyline to odds" do
    assert_equal(0.6, OverUnder.moneyline_to_decimal(-150))
    assert_equal(0.4, OverUnder.moneyline_to_decimal(150))
  end

  test "parse spread text" do
    assert_equal(5.5, OverUnder.parse_spread("5.5"))
    assert_equal(12*0.4, OverUnder.parse_spread("6u50"))
    assert_equal(12*0.6, OverUnder.parse_spread("6o50"))
    assert_equal(0.0, OverUnder.parse_spread(nil))
  end
end
