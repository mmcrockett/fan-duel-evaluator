class GameData
  DATE_KEY="date"
  DATE_STR_KEY="Date"
  DATA_KEY="data"
  FP_KEY  ="Fantasy Points"
  DATE_FORMAT = "%m/%d/%Y"

  attr_reader :date, :data

  def initialize(game_data)
    if (true == game_data.is_a?(self.class))
      @data = game_data.data
      @date = game_data.date
    else
      parse(game_data)
    end
  end

  def fp
    return BigDecimal.new("#{@data[FP_KEY]}")
  end

  def to_s
    return representation.to_s
  end

  def to_json
    return representation.to_json
  end

  private
  def calculate_date(game)
    today = Date.today

    if (false == game.include?(DATE_STR_KEY))
      raise "!ERROR: Unexpected format, expected '#{DATE_STR_KEY}':'#{game}'."
    end

    date = Date.strptime("#{game[DATE_STR_KEY]}/#{today}", DATE_FORMAT)

    if (date > today)
      date = date - 365
    end

    return date
  end

  def parse(game_data)
    if (false == game_data.is_a?(Hash))
      raise Exception.new("!ERROR: Expected a hash '#{game_data.class}':'#{game_data}'.")
    end

    if (false == game_data.include?(DATA_KEY))
      @data = game_data
    else
      @data = game_data["data"]
    end

    if (false == @data.include?(FP_KEY))
      raise "!ERROR: Missing key - '#{FP_KEY}':'#{@data}'."
    end

    if (false == game_data.include?(DATE_KEY))
      @date = calculate_date(@data)
    else
      @date = game_data["date"]
    end
  end

  def representation
    return {:date => @date, :data => @data}
  end
end
