class FanDuelPlayer < ActiveRecord::Base
  def self.parse(data, week)
    players  = []
    json_obj = JSON.load(data)

    json_obj.each_value do |player_data|
      players << FanDuelPlayer.player(player_data, week)
    end

    return players
  end

  def self.player(player_data, week)
    return FanDuelPlayer.new({
      :name     => player_data[1],
      :week     => week,
      :team     => player_data[3].to_i,
      :position => player_data[0],
      :average  => player_data[6].to_f,
      :cost     => player_data[5].to_i,
    })
  end
end
