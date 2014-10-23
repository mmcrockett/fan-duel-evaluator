class FanDuelPlayer < ActiveRecord::Base
  include Auditable

  SINGLE = ["QB", "K", "D", "TE"]
  DOUBLE = ["RB"]
  TRIPLE = ["WR"]

  def defense?
    return (self.position == "D")
  end

  def self.parse(data, week)
    audit = self.get_audit({:week => week, :source => "#{self}", :subsource => ""})

    if (0 == audit.status)
      players  = []
      json_obj = JSON.load(data)
      audit.url = "User Input"
      audit.save

      json_obj.each_value do |player_data|
        players << FanDuelPlayer.player(player_data, week)
      end

      FanDuelPlayer.import(players)
      audit.status = 1
      audit.save
      self.set_week_data(week, self)
    end
  end

  def self.player(player_data, week)
    return FanDuelPlayer.new({
      :name     => player_data[1],
      :week     => week,
      :team_id  => player_data[3].to_i,
      :position => player_data[0],
      :average  => player_data[6].to_f,
      :cost     => player_data[5].to_i,
    })
  end
end
