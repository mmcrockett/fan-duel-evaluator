namespace :fan_duel_evaluator do
  desc "Evaluate the best lineups."
  task(:analyze => :environment) do
    league = ENV['league']
    unique = ENV['unique']

    if (nil == league)
      raise "!ERROR: Usage 'rake fan_duel_evaluator:analys league=NFL."
    end

    if (nil != unique)
      unique = true
    else
      unique = false
    end

    puts "Unique setting is '#{unique}'."

    Roster.analyze(league, unique)
  end

  desc "Dump tables in yml."
  task(:dump => :environment) do
    yaml = Import.where({:league => "NFL"}).first.attributes
    id   = nil
    out  = {}

    yaml.each_pair do |k, v|
      if ("id" == k)
        id = v
      elsif (("created_at" != k) && ("updated_at" != k))
        out[k] = v
      end
    end

    puts "#{{id => out}.to_yaml}"
  end

  desc 'Create YAML test fixtures from data in an existing database. Defaults to development database.  Set RAILS_ENV to override.'
  task :extract_fixtures => :environment do
    sql  = "SELECT * FROM %s"
    skip_tables = ["schema_info", "schema_migrations"]
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      i = "000"
      File.open("test/fixtures/#{table_name}.export.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end

  desc 'Hide non-starting goalies.'
  #var str="";jQuery('img.headshot').each(function(i,x){var n=jQuery(x).attr('alt');str += n.substr(0,n.indexOf(',')) + ',';})
  task :hide_goalies => :environment do
    goalie_names = ENV['GOALIES']
    goalies = []

    if (nil == goalie_names)
      raise "!ERROR: Need environment vairable 'GOALIES' set."
    end

    import = Import.where({:league => "NHL"}).last

    puts "#{goalie_names.split(',')}"
    goalie_names.split(',').each do |goalie_name|
      goalie = FanDuelPlayer.where("import_id = ? AND name LIKE ?", import.id, "%#{goalie_name}").first

      if (nil == goalie)
        raise "!ERROR: '#{goalie_name}' not found."
      else
        goalies << goalie
      end
    end

    non_starters = FanDuelPlayer.where("import_id = ? AND position = ? AND id NOT in (?)", import.id, "G", goalies)

    non_starters.each do |non_starter|
      non_starter.ignore = true
      non_starter.save
    end
  end

  task :nba_data_load => :environment do
    NbaStat.load
  end
end
