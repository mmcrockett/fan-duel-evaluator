require 'open-uri'

class Dvoa < ActiveRecord::Base
  include Auditable

  URL = "http://www.footballoutsiders.com/stats/"
  PAGES = {
    :offense => "teamoff",
    :special => "teamst",
    :defense => "teamdef"
  }
  SUBPAGES = {
    :offense => {
      :pass  => 6,
      :rush  => 8,
      :total => 2
    },
    :special => {
      :total    => 2
    },
    :defense => {
      :pass  => 6,
      :rush  => 8,
      :total => 2
    }
  }

  def self.load(week)
    PAGES.each_pair do |role, role_url|
      records = []
      audit   = self.get_audit({:week => week, :source => "#{self}", :subsource => "#{role}"})

      if (0 == audit.status)
        params = {}
        uri  = "#{URL}/#{role_url}" 
        audit.url = uri
        audit.save
        page = Nokogiri::HTML(open(uri))
        page.css('table.stats')[0].css('tr').each_with_index do |tr, i|
          if ((0 != i) && (1 != i) && (18 != i) && (19 != i))
            team = tr.css('td')[1].text()
            params[:team] = team
            params[:role] = role
            params[:week] = week

            SUBPAGES[role].each_pair do |subrole, td_column|
              params[:value] = 1 + (tr.css('td')[td_column].text().to_f/100)
              params[:subrole] = subrole
              records << self.new(params)
            end
          end
        end
      end

      Dvoa.import(records)
      audit.status = 1
      audit.save()
    end

    self.set_week_data(week, self)
  end

  def self.adjustment(week, position, opponent)
    params = {:week => week, :team => opponent}
    if ("D" == position)
      opponent_offense = Dvoa.find_by(params.merge({:role => :offense, :subrole => :total})).value
      opponent_special = Dvoa.find_by(params.merge({:role => :special, :subrole => :total})).value
      return (1/(opponent_offense*opponent_special))
    else
      if ("RB" == position)
        subrole = :rush
      elsif ("K" == position)
        subrole = :total
      else
        subrole = :pass
      end

      return Dvoa.find_by(params.merge({:role => :defense, :subrole => subrole})).value
    end
  end
end
