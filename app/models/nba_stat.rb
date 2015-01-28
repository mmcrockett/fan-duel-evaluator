require 'uri'
require 'open-uri'

module NbaStat
  def self.remote_load()
    NbaTeam.remote_load
    NbaPlayer.remote_load
    NbaTeamGame.remote_load
    NbaPlayerGame.remote_load
  end

  def create_uri(params = {})
    uri = URI("#{self::URI}")
    uri.query = self::URI_PARAMS.merge(params).to_query

    return uri
  end

  def get_data(params = {})
    uri = create_uri(params)

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

  def matchup_parse(matchup_str)
    matchups = {}

    if (true == matchup_str.include?("@"))
      teams = matchup_str.split("@")
      matchups[:visitor] = teams[0].strip
      matchups[:home]    = teams[1].strip
    elsif (true == matchup_str.include?("vs."))
      teams = matchup_str.split("vs.")
      matchups[:visitor] = teams[1].strip
      matchups[:home]    = teams[0].strip
    else
      raise "!ERROR: Unexpected matchup to parse '#{matchup}'."
    end

    return matchups
  end
end
