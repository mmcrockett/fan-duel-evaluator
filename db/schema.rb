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

ActiveRecord::Schema.define(version: 20141111212914) do

  create_table "fan_duel_players", force: true do |t|
    t.string   "fd_data",                          null: false
    t.string   "game_data"
    t.boolean  "game_data_loaded", default: false
    t.boolean  "ignore",           default: false, null: false
    t.integer  "import_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", force: true do |t|
    t.string   "league",                        null: false
    t.integer  "fd_contest_id",                 null: false
    t.string   "fd_team_data",                  null: false
    t.boolean  "ignore",        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  add_index "rosters", ["import_id"], name: "index_rosters_on_import_id"

end
