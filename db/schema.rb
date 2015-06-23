# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150623192138) do

  create_table "dvoas", force: true do |t|
    t.string   "team"
    t.integer  "import_id"
    t.string   "role"
    t.string   "subrole"
    t.decimal  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dvoas", ["import_id"], name: "index_dvoas_on_import_id"

  create_table "fan_duel_players", force: true do |t|
    t.string   "name",                                                    null: false
    t.integer  "import_id",                                               null: false
    t.integer  "player_id",                                               null: false
    t.integer  "team_id",                                                 null: false
    t.integer  "game_id",                                                 null: false
    t.string   "position",                                                null: false
    t.decimal  "average",         precision: 4, scale: 2,                 null: false
    t.integer  "cost",                                                    null: false
    t.string   "status",                                  default: ""
    t.boolean  "ignore",                                  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "game_data"
    t.boolean  "game_log_loaded",                         default: false
    t.string   "priority",                                default: ""
    t.string   "notes"
  end

  create_table "imports", force: true do |t|
    t.string   "league"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fd_game_id"
  end

  create_table "nba_player_games", force: true do |t|
    t.string   "assigned_season_id", null: false
    t.string   "assigned_game_id",   null: false
    t.date     "game_date",          null: false
    t.string   "visitor",            null: false
    t.string   "home",               null: false
    t.integer  "minutes",            null: false
    t.integer  "points",             null: false
    t.integer  "rebounds",           null: false
    t.integer  "assists",            null: false
    t.integer  "steals",             null: false
    t.integer  "blocks",             null: false
    t.integer  "turnovers",          null: false
    t.integer  "nba_player_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nba_player_games", ["nba_player_id"], name: "index_nba_player_games_on_nba_player_id"

  create_table "nba_players", force: true do |t|
    t.string   "name",               null: false
    t.integer  "assigned_player_id", null: false
    t.integer  "nba_team_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nba_players", ["nba_team_id"], name: "index_nba_players_on_nba_team_id"

  create_table "nba_team_games", force: true do |t|
    t.string   "assigned_game_id", null: false
    t.date     "game_date",        null: false
    t.string   "visitor",          null: false
    t.string   "home",             null: false
    t.integer  "minutes",          null: false
    t.boolean  "win",              null: false
    t.integer  "nba_team_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nba_team_games", ["nba_team_id"], name: "index_nba_team_games_on_nba_team_id"

  create_table "nba_teams", force: true do |t|
    t.string   "name",                                     null: false
    t.integer  "gp",                                       null: false
    t.integer  "assigned_team_id",                         null: false
    t.decimal  "off_rating",       precision: 4, scale: 1, null: false
    t.decimal  "def_rating",       precision: 4, scale: 1, null: false
    t.decimal  "pace",             precision: 4, scale: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "abc"
    t.integer  "niner"
  end

  create_table "nhl_standings", force: true do |t|
    t.string   "team"
    t.integer  "import_id"
    t.integer  "games"
    t.integer  "goals_scored"
    t.integer  "goals_allowed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nhl_standings", ["import_id"], name: "index_nhl_standings_on_import_id"

  create_table "over_unders", force: true do |t|
    t.decimal  "overunder",   precision: 4, scale: 1, null: false
    t.decimal  "home_spread", precision: 4, scale: 1, null: false
    t.string   "home",                                null: false
    t.string   "visitor",                             null: false
    t.integer  "import_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "over_unders", ["import_id"], name: "index_over_unders_on_import_id"

  create_table "rosters", force: true do |t|
    t.integer  "import_id"
    t.string   "notes"
    t.string   "player_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ignore",     default: false
  end

  add_index "rosters", ["import_id"], name: "index_rosters_on_import_id"

end
