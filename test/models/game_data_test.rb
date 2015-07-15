require 'test_helper'

class GameDataTest < ActiveSupport::TestCase
  JSON_GAME_DATA = <<-EOD
  [
    {"Date":"07/02","Opp":"@ATL","IP":"8.1","H":"5","BB":"0","K":"9","ERA":"1.82","W":"0","FP":"15.33"},
    {"Date":"06/26","Opp":"@PHI","IP":"8.0","H":"5","BB":"0","K":"7","ERA":"1.79","W":"1","FP":"17"},
    {"Date":"06/20","Opp":"v PIT","IP":"9.0","H":"0","BB":"0","K":"10","ERA":"1.76","W":"1","FP":"23"}
  ]
  EOD

  JSON_GAME_DATA_NEW_FORMAT = <<-EOD
  [
    {"date":"2015-07-02","data":
      {"Date":"07/02","Opp":"@ATL","IP":"8.1","H":"5","BB":"0","K":"9","ERA":"1.82","W":"0","FP":"15.33"}
    },
    {"date":"2015-06-26","data":
      {"Date":"06/26","Opp":"@PHI","IP":"8.0","H":"5","BB":"0","K":"7","ERA":"1.79","W":"1","FP":"17"}
    },
    {"date":"2015-06-20","data":
      {"Date":"06/20","Opp":"v PIT","IP":"9.0","H":"0","BB":"0","K":"10","ERA":"1.76","W":"1","FP":"23"}
    }
  ]
  EOD

  test "player details" do
    game_data = JSON.parse(JSON_GAME_DATA)
    game_data_new_format = JSON.parse(JSON_GAME_DATA_NEW_FORMAT)

    game_data.each_with_index do |game,i|
      game_data_model = GameData.new(game)

      assert_equal(BigDecimal.new(game["FP"]),game_data_model.fp)
      assert_equal(game_data_new_format[i].to_json,game_data_model.to_json)
    end
  end

  test "player details new" do
    game_data = JSON.parse(JSON_GAME_DATA_NEW_FORMAT)

    game_data.each_with_index do |game,i|
      game_data_model = GameData.new(game)

      assert_equal(BigDecimal.new(game["data"]["FP"]),game_data_model.fp)
      assert_equal(game_data[i].to_json,game_data_model.to_json)
    end
  end
end
