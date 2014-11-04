require 'open-uri'

class Yahoo
  URLS = [
    "http://football.fantasysports.yahoo.com/f1/1236642/players?status=ALL&pos=DEF&cut_type=9&stat1=S_AL4W&myteam=0&sort=NAME&sdir=1",
    "http://football.fantasysports.yahoo.com/f1/1236642/players?status=ALL&pos=DEF&cut_type=9&stat1=S_AL4W&myteam=0&sort=NAME&sdir=1&count=25"
  ]

  def self.load(import_id)
    yahoo_defenses = {}
    URLS.each_with_index do |uri, i|
      page = Nokogiri::HTML(open("#{uri}"))
      page.css('#players-table')[0].css('div.players')[0].css('tbody')[0].css('tr').each do |tr|
        team = tr.css('span.Fz-xxs')[0].text().strip().upcase[0,3].strip()

        if ("JAX" == team)
          team = "JAC"
        end

        yahoo_defenses[team] = tr.css('td')[4].text().strip().to_f
      end
    end

    NflPlayer.where("import_id = ? AND position = ?", import_id, "D").each do |nfl_defense|
      if (false == yahoo_defenses.include?(nfl_defense.team_name))
        raise "!ERROR: Yahoo defenses don't have '#{nfl_defense.id}' - '#{nfl_defense.team_name}' - '#{yahoo_defenses}'."
      end

      nfl_defense.average = yahoo_defenses[nfl_defense.team_name]
      nfl_defense.save()
    end
  end
end
