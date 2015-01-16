require 'uri'
require 'open-uri'

module NbaStat
  def self.load()
    games = []

    NbaTeam.get_data.each do |team|
      ar_team = NbaTeam.where({:id => team['id']}).first_or_create(team)

      if (false == ar_team.new_record?())
        ar_team.update(team)
        ar_team.save
      end

      NbaPlayer.get_data({"TeamID" => ar_team.id}).each do |player|
        ar_player = NbaPlayer.where({:id => player['id']}).first_or_create(player.merge({"nba_team_id" => ar_team.id}))

        if (false == ar_player.new_record?())
         ar_player.update(player)
         ar_player.save
        end

        NbaGame.get_data({"PlayerID" => ar_player.id}).each do |game|
          if (false == NbaGame.exists?({:nba_player_id => ar_player.id, :game_id => game["game_id"]}))
            games <<  NbaGame.new(game)
          end
        end
      end
    end

    NbaGame.import(games)
  end

  def get_data(params = {})
    uri = URI("#{self::URI}")
    uri.query = self::URI_PARAMS.merge(params).to_query

    json_data = JSON.parse(open(uri).read())

    return parse_json(json_data)
  end

  def parse_json(json_data)
    rows = []
    json_rows = []
    data_map  = {}

    json_data["resultSets"].each do |resultSet|
      if (self::RESULT_SET_IDENTIFIER == resultSet["name"])
        headers   = resultSet["headers"]
        json_rows = resultSet["rowSet"]

        self::COLUMN_MAP.each_pair do |k,v|
          i = headers.index(k)

          if (nil == i)
            raise "!ERROR: Couldn't find column '#{k}' in json data '#{headers}'."
          end

          data_map[k] = {:db_column => v, :json_index => i}
        end

        break
      end
    end

    json_rows.each do |row|
      data = {}

      data_map.values.each do |mapping|
        data[mapping[:db_column]] = row[mapping[:json_index]]
      end

      rows << data
    end

    return rows
  end
end
