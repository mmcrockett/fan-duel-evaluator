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
      :fg_xp    => 6,
      :kick     => 7,
      :kick_ret => 8,
      :punt     => 9,
      :punt_ret => 10
    },
    :defense => {
      :pass  => 6,
      :rush  => 8,
      :total => 2
    }
  }

  def self.load(week)
    PAGES.each_type do |type, url_part|
      audit = self.get_audit({:week => week, :type => "#{Dvoa.class}", :subtype => "#{type}"})

      if (0 == audit.status)
        params = {}
        dvoas  = []
        uri  = "#{URL}/#{page_url}" 
        audit.url = uri
        audit.save
        page = Nokogiri::HTML(open(uri))
        page.css('table.stats')[0].css('tr').each_with_index do |tr, i|
          if ((0 != i) && (1 != i) && (18 != i) && (19 != i))
            team = tr.css('td')[1].text()
            params[:team] = team
            params[:type] = type

            SUBPAGES[type].each_pair do |subtype, td_column|
              value = tr.css('td')[td_column].text().to_f
              dvoas << self.new(params.merge({:subtype => subtype, :value => value})
            end
          end
        end
      end

      Dvoa.import(dvoas)
      audit.status = 1
      audit.save
      self.set_week_data(week, "#{Dvoa.class}")
    end
  end
end
