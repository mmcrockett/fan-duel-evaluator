require 'csv'
require File.expand_path('../../../app/models/array_mod.rb', __FILE__)

namespace :fan_duel_evaluator do
  desc "Load NBA ARFF data."
  task(:nba_arff => :environment) do
    puts "@relation nba_players"

    attributes = {
      "cost"        => "NUMERIC",
      "result"      => "NUMERIC",
      "resultgrade" => "{A,B,C,D,F}",
      "import_id"   => "STRING",
      "name"        => "STRING",
      "position"    => "{#{FanDuelNbaPlayer::POSITIONS.uniq * ','}}",
      "pts_last"    => "NUMERIC",
      "reb_last"    => "NUMERIC",
      "asst_last"   => "NUMERIC",
      "stl_last"    => "NUMERIC",
      "blk_last"    => "NUMERIC",
      "to_last"     => "NUMERIC",
      "min_last"    => "NUMERIC",
      "pts_m3"      => "NUMERIC",
      "reb_m3"      => "NUMERIC",
      "asst_m3"     => "NUMERIC",
      "stl_m3"      => "NUMERIC",
      "blk_m3"      => "NUMERIC",
      "to_m3"       => "NUMERIC",
      "min_m3"      => "NUMERIC",
      "pts_m5"      => "NUMERIC",
      "reb_m5"      => "NUMERIC",
      "asst_m5"     => "NUMERIC",
      "stl_m5"      => "NUMERIC",
      "blk_m5"      => "NUMERIC",
      "to_m5"       => "NUMERIC",
      "min_m5"      => "NUMERIC",
      "pts_m10"     => "NUMERIC",
      "reb_m10"     => "NUMERIC",
      "asst_m10"    => "NUMERIC",
      "stl_m10"     => "NUMERIC",
      "blk_m10"     => "NUMERIC",
      "to_m10"      => "NUMERIC",
      "min_m10"     => "NUMERIC",
    }

    attributes.each_pair do |k,v|
      puts "@attribute '#{k}' #{v}"
    end

    puts "@data"

    Import.select("max(id) as id").where("league = ? and fd_game_id not null and id > ?", "NBA", 0).group("fd_game_id").pluck(:id).each do |import_id|
      fd_players = FanDuelNbaPlayer.where({:ignore => false, :import_id => import_id})

      fd_players.each do |fd_player|
        output = []
        arff_data = {
          :points    => [],
          :rebounds  => [],
          :assists   => [],
          :steals    => [],
          :blocks    => [],
          :turnovers => [],
          :minutes   => []
        }
        nba_player = NbaPlayer.lookup_by_fd_player(fd_player)

        if (nil != nba_player)
          output << fd_player.cost
          output << (NbaPlayerGame.actual_points([fd_player]) - fd_player.avg).round(1)

          if (output[-1] < -18)
            output << 'F'
          elsif (output[-1] < -9)
            output << 'D'
          elsif (output[-1] < 0)
            output << 'C'
          elsif (output[-1] < 9)
            output << 'B'
          else
            output << 'A'
          end

          output << fd_player.import_id
          output << "'#{fd_player.name.gsub("'", "\\'")}'"
          output << fd_player.pos


          nba_player.raw_game_data(fd_player.created_at.to_date).each_with_index do |nba_player_game, i|
            arff_data.keys.each do |k|
              arff_data[k] << nba_player_game.send(k)
            end

            if (true == [1,3,5,10].include?(i + 1))
              arff_data.keys.each do |k|
                output << arff_data[k].mean.round(1)
              end
            end
          end

          while (attributes.size > output.size)
            output << '?'
          end

          puts "#{output * ','}"
        end
      end
    end
  end

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
    NbaStat.remote_load
  end

  task :nba_sample_urls => :environment do
    puts "#{NbaTeam.create_uri()}"
    puts "#{NbaPlayer.create_uri({"TeamID" => 1610612737})}"
    puts "#{NbaTeamGame.create_uri({"TeamID" => 1610612737})}"
    puts "#{NbaPlayerGame.create_uri({"PlayerID" => 201143})}"
  end

  task :nba_evaluate_strategies => :environment do
    puts "import,strategy,expected,actual"

    Import.select("max(id) as id").where("league = ? and fd_game_id not null and id > ?", "NBA", 0).group("fd_game_id").pluck(:id).each do |import_id|
      fd_players = FanDuelNbaPlayer.where({:ignore => false, :import_id => import_id})
      fd_evaluation_players = []

      fd_players.each do |fd_player|
        nba_player = NbaPlayer.lookup_by_fd_player(fd_player)

        if (nil != nba_player)
          fd_player.game_data = nba_player.game_data(fd_player.created_at.to_date)

          nickname = fd_player.team_name
          game = NbaTeamGame.where("game_date = ? and (home = ? or visitor = ?)", fd_player.created_at.to_date, nickname, nickname).first

          if (nil != game)
            oppnickname = ([game.home, game.visitor] - [nickname])[0]

            team     = NbaTeam.where(:name => NbaTeam.team_name(nickname)).first
            opponent = NbaTeam.where(:name => NbaTeam.team_name(oppnickname)).first

            exp = (1.0 * (team.pace/100) * (opponent.pace/100) * (team.off_rating/100) * (opponent.def_rating/100)).round(3)
            fd_player.expavg = (fd_player.avg * exp).round(1)
            fd_evaluation_players << fd_player
          else
            puts "!WARNING: Couldn't find team game '#{fd_player.created_at.to_date}':'#{nickname}':#{fd_player.name}:#{fd_player.id}."
          end
        end
      end

      srosters   = Roster.get_best_rosters(fd_evaluation_players, FanDuelNbaPlayer::POSITIONS, FanDuelNbaPlayer::BUDGET, [:mean,:med,:avg,:expavg,:p80], false)

      srosters.each_pair do |name, sroster|
        if (sroster != nil)
          puts "#{import_id},#{name},#{sroster.points.round(1)},#{NbaPlayerGame.actual_points(sroster.players).round(1)}"
        else
          puts "#{import_id},#{name},unknown,unknown"
        end
      end
    end
  end

  task :strategy_similarities => :environment do
    filename = ENV['target']
    data = {}
    outcomes = {}

    if (nil == filename)
      raise "!ERROR: Usage 'rake fan_duel_evaluator:strategy_similarities target=strategy_evaluation.csv"
    end

    CSV.foreach(filename) do |row|
      if (true == row[1].include?("_"))
        substrategy = row[1].split("_")[1]
        actual      = row[3]
        if ("unknown" != actual)
          outcomes[substrategy] = {:predicted => row[2], :actual => actual.to_f}
        end
      else
        outcomes.keys.each do |substrategy1|
          data[substrategy1] ||= {}
          outcomes.keys.each do |substrategy2|
            data[substrategy1][substrategy2] ||= {:equal => 0, :total => 0}

            if ((outcomes[substrategy1][:predicted] == outcomes[substrategy2][:predicted]) &&
                (outcomes[substrategy1][:actual] == outcomes[substrategy2][:actual])
              )
              data[substrategy1][substrategy2][:equal] += 1
            end
            data[substrategy1][substrategy2][:total] += 1
          end
        end

        outcomes = {}
      end
    end

    puts ",#{data.keys * ','}"

    data.keys.each do |strategy1|
      data.keys.each_with_index do |strategy2, i|
        if (0 == i)
          print "#{strategy1}"
        end

        print ",#{((data[strategy1][strategy2][:equal] * 100.0)/data[strategy1][strategy2][:total]).round(0)}"
      end
      puts ""
    end
  end

  task :strategy_best_evaluation => :environment do
    filename = ENV['target']
    data = {}
    outcomes = {}
    max = 0
    total = 0

    if (nil == filename)
      raise "!ERROR: Usage 'rake fan_duel_evaluator:strategy_best_evaluation target=strategy_evaluation.csv"
    end

    CSV.foreach(filename) do |row|
      if (true == row[1].include?("_"))
        substrategy = row[1].split("_")[1]
        actual      = row[3]
        if ("unknown" != actual)
          outcomes[substrategy] = {:predicted => row[2].to_f, :actual => actual.to_f}

          if (outcomes[substrategy][:actual] > max)
            max = outcomes[substrategy][:actual]
          end
        end
      else
        outcomes.keys.each do |substrategy|
          data[substrategy] ||= 0

          if (outcomes[substrategy][:actual] > max)
            raise "!ERROR: actual value '#{outcomes[substrategy][:actual]}' greater than max '#{max}'."
          elsif (max == outcomes[substrategy][:actual])
            data[substrategy] += 1
          end
        end

        outcomes = {}
        max      = 0
        total   += 1
      end
    end

    puts "Strategy,Best Count,Total Count"
    data.keys.each do |strategy|
      puts "#{strategy},#{data[strategy]},#{total}"
    end
  end

  task :strategy_evaluation => :environment do
    fd_data = {
      :fifty  => [258.8,259.5,261.6,287.9,281.6,244.3,239.9,291.9,299.6,242.2,282,279.5,264.5,255.5],
      :triple => [245.4,297.1,295.8,297.1,250.7,282,308.5,249.3,247.5,294.2,283.2],
    }
    filename = ENV['target']
    data = {}
    max = 0
    total = 0
    import_data = {}
    actual_data = {}
    DATE_FORMAT = "%Y-%m-%d"
    IMPORT_DATA_RAW = {
      6 => Date.strptime("2014-11-10", DATE_FORMAT),
      7 => Date.strptime("2014-11-11", DATE_FORMAT),
      10 => Date.strptime("2014-11-12", DATE_FORMAT),
      13 => Date.strptime("2014-11-14", DATE_FORMAT),
      16 => Date.strptime("2014-11-15", DATE_FORMAT),
      19 => Date.strptime("2014-11-17", DATE_FORMAT),
      23 => Date.strptime("2014-11-19", DATE_FORMAT),
      27 => Date.strptime("2014-11-21", DATE_FORMAT),
      48 => Date.strptime("2014-11-22", DATE_FORMAT),
      49 => Date.strptime("2014-11-23", DATE_FORMAT),
      51 => Date.strptime("2014-11-24", DATE_FORMAT),
      54 => Date.strptime("2014-11-25", DATE_FORMAT),
      56 => Date.strptime("2014-11-26", DATE_FORMAT),
      59 => Date.strptime("2014-11-28", DATE_FORMAT),
      60 => Date.strptime("2014-11-30", DATE_FORMAT),
      62 => Date.strptime("2014-12-01", DATE_FORMAT),
      70 => Date.strptime("2014-12-02", DATE_FORMAT),
      76 => Date.strptime("2014-12-03", DATE_FORMAT),
      78 => Date.strptime("2014-12-04", DATE_FORMAT),
      82 => Date.strptime("2014-12-05", DATE_FORMAT),
      86 => Date.strptime("2014-12-19", DATE_FORMAT),
      87 => Date.strptime("2014-12-20", DATE_FORMAT),
      92 => Date.strptime("2014-12-22", DATE_FORMAT),
      94 => Date.strptime("2014-12-28", DATE_FORMAT),
      95 => Date.strptime("2014-12-29", DATE_FORMAT),
      100 => Date.strptime("2014-12-30", DATE_FORMAT),
      102 => Date.strptime("2015-01-01", DATE_FORMAT),
      108 => Date.strptime("2015-01-03", DATE_FORMAT),
      111 => Date.strptime("2015-01-05", DATE_FORMAT),
      115 => Date.strptime("2015-01-06", DATE_FORMAT),
    }
    ACTUAL_DATA_RAW = [
      {
        :date => Date.strptime("11/24/2014", "%m/%d/%Y"),
        :value => 258.8},
      {
        :date => Date.strptime("11/25/2014", "%m/%d/%Y"),
        :value => 259.5},
      {
        :date => Date.strptime("11/25/2014", "%m/%d/%Y"),
        :value => 261.6},
      {
        :date => Date.strptime("11/26/2014", "%m/%d/%Y"),
       :value =>  287.9},
      {
        :date => Date.strptime("11/26/2014", "%m/%d/%Y"),
       :value =>  281.6},
      {
        :date => Date.strptime("11/28/2014", "%m/%d/%Y"),
       :value =>  244.3},
      {
        :date => Date.strptime("11/28/2014", "%m/%d/%Y"),
       :value =>  239.9},
      {
        :date => Date.strptime("11/30/2014", "%m/%d/%Y"),
       :value =>  291.9},
      {
        :date => Date.strptime("11/30/2014", "%m/%d/%Y"),
       :value =>  299.6},
      {
        :date => Date.strptime("12/1/2014", "%m/%d/%Y"),
       :value =>  242.2},
      {
        :date => Date.strptime("12/1/2014", "%m/%d/%Y"),
       :value =>  245.4},
      {
        :date => Date.strptime("12/2/2014", "%m/%d/%Y"),
       :value =>  297.1},
      {
        :date => Date.strptime("12/2/2014", "%m/%d/%Y"),
       :value =>  295.8},
      {
        :date => Date.strptime("12/3/2014", "%m/%d/%Y"),
        :value => 297.1},
      {
        :date => Date.strptime("12/4/2014", "%m/%d/%Y"),
        :value => 250.7},
      {
        :date => Date.strptime("12/5/2014", "%m/%d/%Y"),
       :value =>  282},
      {
        :date => Date.strptime("12/5/2014", "%m/%d/%Y"),
       :value =>  282},
      {
        :date => Date.strptime("12/5/2014", "%m/%d/%Y"),
       :value =>  279.5},
      {
        :date => Date.strptime("12/19/2014", "%m/%d/%Y"),
        :value => 308.5},
      {
        :date => Date.strptime("12/20/2014", "%m/%d/%Y"),
        :value => 249.3},
      {
        :date => Date.strptime("12/22/2014", "%m/%d/%Y"),
        :value => 247.5},
      {
        :date => Date.strptime("12/28/2014", "%m/%d/%Y"),
        :value => 294.2},
      {
        :date => Date.strptime("12/29/2014", "%m/%d/%Y"),
        :value => 264.5},
      {
        :date => Date.strptime("12/30/2014", "%m/%d/%Y"),
        :value => 246},
      {
        :date => Date.strptime("1/3/2015", "%m/%d/%Y"),
        :value => 283.2},
      {
        :date => Date.strptime("1/5/2015", "%m/%d/%Y"),
        :value => 255.5},
    ]

    ACTUAL_DATA_RAW.each do |entry|
      actual_data[entry[:date]] ||= []
      actual_data[entry[:date]] << entry[:value]
    end

    IMPORT_DATA_RAW.each_pair do |import_id, import_date|
      if (true == actual_data.include?(import_date))
        import_data["#{import_id}"] = actual_data[import_date].mean.round(1)
      end
    end

    if (nil == filename)
      raise "!ERROR: Usage 'rake fan_duel_evaluator:strategy_best_evaluation target=strategy_evaluation.csv"
    end

    current_import_id = nil
    best = {:predicted => 0.0, :actual => 0.0}

    CSV.foreach(filename) do |row|
      import_id = row[0]
      current_import_id ||= import_id
      strategy = row[1]
      predicted = row[2].to_f
      actual   = row[3]
      data[strategy] ||= {}
      data[strategy][:raw] ||= []
      data[strategy][:total] ||= 0
      data[strategy][:triple] ||= 0
      data[strategy][:fifty] ||= 0
      data[strategy][:actual] ||= 0
      data[strategy][:actualtotal] ||= 0

      if (import_id != current_import_id)
        if (0 == best[:actual])
          puts "#{import_id}:#{current_import_id}"
        end
        data[:best] ||= {}
        data[:best][:raw] ||= []
        data[:best][:total] ||= 0
        data[:best][:triple] ||= 0
        data[:best][:fifty] ||= 0
        data[:best][:raw] << best[:actual]
        data[:best][:total] += 1

        if (best[:actual] >= fd_data[:fifty].median.round(1))
          data[:best][:fifty] += 1
        end

        if (best[:actual] >= fd_data[:triple].median.round(1))
          data[:best][:triple] += 1
        end
        current_import_id = import_id
        best = {:predicted => 0.0, :actual => 0.0}
      end

      if ("unknown" != actual)
        actual = actual.to_f
        data[strategy][:raw] << actual
        data[strategy][:total] += 1

        if (actual >= fd_data[:fifty].median.round(1))
          data[strategy][:fifty] += 1
        end

        if (actual >= fd_data[:triple].median.round(1))
          data[strategy][:triple] += 1
        end

        if (nil != import_data[import_id])
          data[strategy][:actualtotal] += 1
          if (actual >= import_data[import_id])
            data[strategy][:actual] += 1
          end
        end

        if (best[:predicted] <= predicted)
          best = {:predicted => predicted, :actual => actual}
        end
      end
    end

    puts "Strategy,Max,Min,Mean,Median,Fifty,Triple,Total,Actual,ActualTotal"
    data.each_pair do |strategy,value|
      raw = value[:raw]
      puts "#{strategy},#{raw.max},#{raw.min},#{raw.mean.round(1)},#{raw.median.round(1)},#{value[:fifty]},#{value[:triple]},#{value[:total]},#{value[:actual]},#{value[:actualtotal]}"
    end

    fd_data.each_pair do |k,v|
      puts "#{k},#{v.max},#{v.min},#{v.mean.round(1)},#{v.median.round(1)}"
    end
  end
end
