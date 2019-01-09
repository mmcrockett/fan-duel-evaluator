require 'open-uri'

class Dvoa < ActiveRecord::Base
  belongs_to :import

  URL = "https://www.footballoutsiders.com/stats/"
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

  def self.load(import_id)
    PAGES.each_pair do |role, role_url|
      records = []

      params = {}
      uri  = "#{URL}/#{role_url}" 
      page = Nokogiri::HTML(open(uri))
      page.css('table.stats')[0].css('tr').each_with_index do |tr, i|
        puts "DVOA: #{i}:#{tr}"
        if ((0 < tr.css('td').size) && (0 != tr.css('td')[0].text().to_i))
          team = tr.css('td')[1].text()
          params[:team] = team
          params[:role] = role
          params[:import_id] = import_id

          SUBPAGES[role].each_pair do |subrole, td_column|
            params[:value] = 1 + (tr.css('td')[td_column].text().to_f/100)
            params[:subrole] = subrole
            records << self.new(params)
          end
        end
      end

      Dvoa.import(records)
    end
  end

  def self.adjustment(import_id, position, opponent)
    params = {:import_id => import_id, :team => opponent}
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
