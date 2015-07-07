require 'csv'
require File.expand_path('../../../app/models/array_mod.rb', __FILE__)

namespace :fan_duel_evaluator do
  desc "Evaluate the best lineups."
  task(:analyze => :environment) do
    league = ENV['league']
    unique = ENV['unique']

    if (nil == league)
      raise "!ERROR: Usage 'rake fan_duel_evaluator:analyze league=NFL."
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
    #wclause = "WHERE (visitor = 'BOS' or home = 'BOS') and game_date <= '"2014-12-14' and game_date >= '"2014-11-15'"
    #wclause = "WHERE id = 1869"
    sql  = "SELECT * FROM %s #{wclause}"
    ActiveRecord::Base.establish_connection
    skip_tables = ["schema_info", "schema_migrations"]
    #do_tables   = ActiveRecord::Base.connection.tables
    do_tables   = ["nba_team_games"]
    (do_tables - skip_tables).each do |table_name|
      i = "200"
      File.open("test/fixtures/#{table_name}.export.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end
end
