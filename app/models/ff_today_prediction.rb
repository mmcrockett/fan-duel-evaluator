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
end
