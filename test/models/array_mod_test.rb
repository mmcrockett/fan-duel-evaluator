require 'test_helper'

class ArrayModTest < ActiveSupport::TestCase
  def setup
    @sample_array = [2,4,4,4,5,5,7,9]
  end

  test "mean" do
    assert_equal(0, [].mean)
    assert_equal(5, @sample_array.mean)
  end

  test "variance" do
    assert_equal(0, [].variance)
    assert_equal(4, @sample_array.variance)
  end

  test "stddev" do
    assert_equal(0, [].stddev)
    assert_equal(2, @sample_array.stddev)
  end

  test "tolerance" do
    assert_equal((5.0 - (2 * 1.28155)), @sample_array.tolerance)
    assert_equal((5.0 - (2 * 1.64485)), @sample_array.tolerance(90))
  end

  test "median" do
    assert_equal(0, [].median)
    assert_equal(4.5, @sample_array.median)
    assert_equal(4, @sample_array.shift(@sample_array.size - 2).median)
  end
end
