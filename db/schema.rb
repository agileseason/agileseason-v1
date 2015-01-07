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

ActiveRecord::Schema.define(version: 20150107181004) do

  create_table "board_histories", force: true do |t|
    t.integer  "board_id"
    t.date     "collected_on"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "board_histories", ["board_id"], name: "index_board_histories_on_board_id"

  create_table "boards", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "type"
    t.integer  "github_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "github_name"
  end

  add_index "boards", ["user_id"], name: "index_boards_on_user_id"

  create_table "columns", force: true do |t|
    t.integer  "board_id"
    t.string   "name"
    t.string   "color"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "columns", ["board_id"], name: "index_columns_on_board_id"

  create_table "repo_histories", force: true do |t|
    t.integer  "board_id"
    t.date     "collected_on"
    t.integer  "lines"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repo_histories", ["board_id"], name: "index_repo_histories_on_board_id"

  create_table "users", force: true do |t|
    t.string   "email",           null: false
    t.string   "github_username", null: false
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
