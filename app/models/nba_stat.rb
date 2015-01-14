require 'uri'
require 'open-uri'

class NbaStat < ActiveRecord::Base
  def self.get_data
    uri = URI("#{self::URI}")
    uri.query = self::URI_PARAMS.to_query

    json_data = JSON.parse(open(uri).read())

    return self.parse_json(json_data)
  end

  def self.parse_json(json_data)
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
      end

      break
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
