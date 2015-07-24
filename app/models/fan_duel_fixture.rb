class FanDuelFixture
  DATE_FORMAT = "%Y-%m-%dT%H:%M:%S%Z"

  def initialize(fixture, teams_by_id = {})
    @teams_by_id = teams_by_id
    @fixture     = fixture
  end

  def home_team_id
    return member(@fixture["home_team"]).to_i
  end

  def home_team
    if (false == @teams_by_id.include?(self.home_team_id))
      raise "!ERROR: Home team not found '#{self.home_team_id}'. '#{@teams_by_id.keys}'."
    end

    return @teams_by_id[self.home_team_id]
  end

  def visitor_team_id
    return member(@fixture["away_team"]).to_i
  end

  def visitor_team
    if (false == @teams_by_id.include?(self.visitor_team_id))
      raise "!ERROR: Visitor team not found '#{self.visitor_team_id}'. '#{@teams_by_id.keys}'."
    end

    return @teams_by_id[self.visitor_team_id]
  end

  def gametime
    return Time.strptime(@fixture["start_date"], DATE_FORMAT).in_time_zone('America/New_York')
  end

  private
  def member(v)
    return v["team"]["_members"][0]
  end
end
