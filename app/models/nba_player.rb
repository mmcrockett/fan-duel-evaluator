class NbaPlayer < ActiveRecord::Base 
  extend NbaStat

  belongs_to :nba_team

  URI = "http://stats.nba.com/stats/commonteamroster"
  RESULT_SET_IDENTIFIER = "CommonTeamRoster"
  COLUMN_MAP = {
    "PLAYER_ID" => "id",
    "PLAYER"    => "name",
  }
  URI_PARAMS = {
    "Season"   => "2014-15",
    "LeagueID" => "00"
  }
  def self.load
    players  = []
    aplayers = []

    NbaTeam.all.each do |team|
      NbaPlayer.get_data({"TeamID" => team.id}).each do |player|
        ar_player = NbaPlayer.where({:id => player['id']}).first_or_create(player.merge({"nba_team_id" => team.id}))

        if (false == ar_player.new_record?())
         ar_player.update(player)
         aplayers << ar_player
        else
          players << ar_player
        end
      end
    end

    NbaPlayer.import(players)

    if (0 != aplayers)
      NbaPlayer.transaction do
        aplayers.each do |aplayer|
          aplayer.save
        end
      end
    end
  end
end
