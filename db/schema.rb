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

ActiveRecord::Schema.define(version: 20141106003020) do

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
    t.string   "name",                                               null: false
    t.integer  "import_id",                                          null: false
    t.integer  "player_id",                                          null: false
    t.integer  "team_id",                                            null: false
    t.integer  "game_id",                                            null: false
    t.string   "position",                                           null: false
    t.decimal  "average",    precision: 4, scale: 2,                 null: false
    t.integer  "cost",                                               null: false
    t.string   "status",                             default: ""
    t.string   "note",                               default: ""
    t.boolean  "ignore",                             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", force: true do |t|
    t.string   "league"
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

end
