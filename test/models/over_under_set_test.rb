require 'test_helper'

class OverUnderSetTest < ActiveSupport::TestCase
  test "home and away calculation" do
    overunderset = OverUnderSet.new(Import.find(11))

    assert_equal(11, overunderset.import_id)
    assert_equal(654, overunderset.scores.sum)
    assert_equal("STL", overunderset.get_opponent("DEN"))
    assert_equal("DEN", overunderset.get_opponent("STL"))
    assert_equal(30.25, overunderset.get_exp_score("DEN"))
    assert_equal(20.75, overunderset.get_exp_score("STL"))
  end

  test "expectation" do
    overunderset = OverUnderSet.new(Import.find(12))

    assert_equal(1.0/3.0, overunderset.multiplier("TWELVE_HOME").to_f)
    assert_equal(1.0/3.0, overunderset.multiplier("EIGHT_VISITOR", {:defensive => true}).to_f)
    assert_equal(-1.0/3.0, overunderset.multiplier("SIX_HOME").to_f)

    assert_equal(33, overunderset.multiplier("TWELVE_HOME", {:output => :percentage}))
    assert_equal(33, overunderset.multiplier("EIGHT_VISITOR", {:defensive => true, :output => :percentage}))
    assert_equal(-33, overunderset.multiplier("SIX_HOME", {:output => :percentage}))

    assert_equal(1.333, overunderset.multiplier("TWELVE_HOME", {:output => :adjustment}))
    assert_equal(1.333, overunderset.multiplier("EIGHT_VISITOR", {:defensive => true, :output => :adjustment}))
    assert_equal(0.667, overunderset.multiplier("SIX_HOME", {:output => :adjustment}))
  end
end
