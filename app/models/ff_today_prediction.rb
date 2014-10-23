require 'open-uri'

class FfTodayPrediction < ActiveRecord::Base
  include Auditable

  URL = "http://fftoday.com/stats/fantasystats.php"

  URL_PARAMS = {
    :o => 3,
    :PosID => nil,
    :Data  => "Last5",
    :Show1 => nil,
    :Show2 => nil,
    #:LeagueID => 107644
    :LeagueID => 117791
  }

  POSITION = {
    "QB" => 10,
    "RB" => 20,
    "WR" => 30,
    "TE" => 40,
    "K"  => 80,
    "D"  => 99
  }

  def self.load(week)
    url_params = URL_PARAMS
    url_params[:Show1] = week
    url_params[:Show2] = week

    POSITION.each_pair do |position, position_id|
      records = []
      url_params[:PosID] = position_id
      audit   = self.get_audit({:week => week, :source => "#{self}", :subsource => "#{position}"})

      if (0 == audit.status)
        params = {:position => position}
        uri    = "#{URL}?#{url_params.to_query}"
        audit.url = uri
        audit.save
        page = Nokogiri::HTML(open(uri))
        page.css('td.tablehdrsmall').each do |td|
          parent = td.parent
          params[:team]   = td.css('strong')[0].text().strip()
          params[:week]   = week
          opponent_td = parent.css('td.smallestbody')
          percent  = opponent_td.css('span').text().strip()
          params[:opponent] = opponent_td.text().strip().delete(percent).delete("@")
          params[:value] = 1 + (percent.delete("%").to_f/100)
          records << self.new(params)
        end
      end

      FfTodayPrediction.import(records)
      audit.status = 1
      audit.save()
    end

    self.set_week_data(week, self)
  end

  def self.translate_team_name(name)
    teams = FfTodayPrediction.distinct.pluck(:team)
    parts = name.upcase.split(" ")
    city_first_three   = parts[0][0,3]
    city_first_letters = parts[0][0] + parts[1][0]
    all_first_letters  = "missing"

    if (nil != parts[2])
      all_first_letters  = parts[0][0] + parts[1][0] + parts[2][0]
      st_louis_rams      = parts[0][0,2] + parts[1][0]
    end

    if (true == teams.include?(city_first_three))
      return city_first_three
    elsif (true == teams.include?(city_first_letters))
      return city_first_letters
    elsif (true == teams.include?(all_first_letters))
      return all_first_letters
    elsif (true == teams.include?(st_louis_rams))
      return st_louis_rams
    else
      raise "!ERROR: Couldn't translate NFL name '#{name}' - '#{parts}' - '#{teams}'"
    end
  end

  def self.adjustment(week, position, team)
    return FfTodayPrediction.find_by({:week => week, :team => team, :position => position}).value
  end
end
