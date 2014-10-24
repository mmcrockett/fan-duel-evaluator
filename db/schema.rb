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

ActiveRecord::Schema.define(version: 20141024162320) do

  create_table "audits", force: true do |t|
    t.string   "source",                 null: false
    t.string   "subsource",              null: false
    t.integer  "week",                   null: false
    t.integer  "status",     default: 0, null: false
    t.string   "url",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dvoas", force: true do |t|
    t.string   "team",                               null: false
    t.integer  "week",                               null: false
    t.string   "role",                               null: false
    t.string   "subrole",                            null: false
    t.decimal  "value",      precision: 4, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fan_duel_players", force: true do |t|
    t.string   "name",                                               null: false
    t.integer  "week",                                               null: false
    t.integer  "team_id",                                            null: false
    t.string   "position",                                           null: false
    t.decimal  "average",    precision: 4, scale: 2,                 null: false
    t.integer  "cost",                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                             default: ""
    t.string   "note",                               default: ""
    t.boolean  "ignore",                             default: false, null: false
  end

  create_table "ff_today_predictions", force: true do |t|
    t.string   "position",                           null: false
    t.integer  "week",                               null: false
    t.string   "team",                               null: false
    t.string   "opponent",                           null: false
    t.decimal  "value",      precision: 4, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "week_data", force: true do |t|
    t.integer  "week",                       null: false
    t.boolean  "fan_duel",   default: false
    t.boolean  "yahoo",      default: false
    t.boolean  "dvoa",       default: false
    t.boolean  "fftoday",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "yahoos", force: true do |t|
    t.string   "team",                               null: false
    t.integer  "week",                               null: false
    t.decimal  "average",    precision: 4, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
