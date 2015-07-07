require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  test "url import" do
    return true
    params = Import.parse("https://www.fanduel.com/games/12564/contests/12564-13442827/enter")

    assert_equal("CBB", params[:league])
    assert_equal("11276", params[:fd_contest_id])
    assert_equal("TEMPL",params[:teams]["1104"])
  end
end
