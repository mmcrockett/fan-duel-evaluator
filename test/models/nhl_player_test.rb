require 'test_helper'

class NhlPlayerTest < ActiveSupport::TestCase
  def setup
  end

  test "unified_name_parser" do
    player = NhlPlayer.new()
    assert_equal("CPrice", player.unified_name("Carey Price"))
    assert_equal("CPrice", player.unified_name("Price, Carey"))
    assert_equal("MFleury", player.unified_name("Marc-Andre Fleury"))
    assert_equal("Fleury", player.unified_name("Fleury"))
  end
end
