require 'open-uri'

class Yahoo < ActiveRecord::Base
  include Auditable

  URLS = [
    "http://football.fantasysports.yahoo.com/f1/1236642/players?status=ALL&pos=DEF&cut_type=9&stat1=S_AL4W&myteam=0&sort=NAME&sdir=1",
    "http://football.fantasysports.yahoo.com/f1/1236642/players?status=ALL&pos=DEF&cut_type=9&stat1=S_AL4W&myteam=0&sort=NAME&sdir=1&count=25"
  ]

  def self.load(week)
    URLS.each_with_index do |uri, i|
      records = []
      audit   = self.get_audit({:week => week, :source => "#{self}", :subsource => "page #{i}"})

      if (0 == audit.status)
        params = {}
        audit.url = uri
        audit.save
        page = Nokogiri::HTML(open("#{uri}"))
        page.css('#players-table')[0].css('div.players')[0].css('tbody')[0].css('tr').each do |tr|
          params[:team]    = tr.css('span.Fz-xxs')[0].text().strip().upcase[0,3].strip()
          params[:week]    = week
          params[:average] = tr.css('td')[4].text().strip().to_f

          if ("JAX" == params[:team])
            params[:team] = "JAC"
          end

          records << self.new(params)
        end
      end

      Yahoo.import(records)
      audit.status = 1
      audit.save()
    end

    self.set_week_data(week, self)
  end
end
