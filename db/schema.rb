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

ActiveRecord::Schema.define(version: 20150901035817) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "board_id"
    t.integer  "issue_stat_id"
    t.string   "type"
    t.text     "data"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "activities", ["board_id"], name: "index_activities_on_board_id", using: :btree
  add_index "activities", ["issue_stat_id"], name: "index_activities_on_issue_stat_id", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "board_histories", force: :cascade do |t|
    t.integer  "board_id"
    t.date     "collected_on"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "board_histories", ["board_id"], name: "index_board_histories_on_board_id", using: :btree
  add_index "board_histories", ["collected_on", "board_id"], name: "index_board_histories_on_collected_on_and_board_id", unique: true, using: :btree

  create_table "boards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "type"
    t.integer  "github_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "github_name"
    t.text     "settings"
    t.string   "github_full_name", limit: 500
    t.datetime "subscribed_at"
    t.string   "github_hook_id"
    t.boolean  "is_public",                    default: false
  end

  add_index "boards", ["user_id"], name: "index_boards_on_user_id", using: :btree

  create_table "columns", force: :cascade do |t|
    t.integer  "board_id"
    t.string   "name"
    t.string   "color"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "issues"
    t.integer  "wip_min"
    t.integer  "wip_max"
    t.boolean  "is_auto_assign"
  end

  add_index "columns", ["board_id"], name: "index_columns_on_board_id", using: :btree

  create_table "issue_stats", force: :cascade do |t|
    t.integer  "board_id"
    t.integer  "number"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "archived_at"
    t.integer  "column_id"
    t.datetime "due_date_at"
    t.boolean  "is_ready",    default: false
  end

  add_index "issue_stats", ["board_id"], name: "index_issue_stats_on_board_id", using: :btree
  add_index "issue_stats", ["column_id"], name: "index_issue_stats_on_column_id", using: :btree
  add_index "issue_stats", ["number", "board_id"], name: "index_issue_stats_on_number_and_board_id", unique: true, using: :btree

  create_table "lifetimes", force: :cascade do |t|
    t.integer  "issue_stat_id"
    t.integer  "column_id"
    t.datetime "in_at"
    t.datetime "out_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "lifetimes", ["column_id"], name: "index_lifetimes_on_column_id", using: :btree
  add_index "lifetimes", ["issue_stat_id"], name: "index_lifetimes_on_issue_stat_id", using: :btree

  create_table "repo_histories", force: :cascade do |t|
    t.integer  "board_id"
    t.date     "collected_on"
    t.integer  "lines"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repo_histories", ["board_id"], name: "index_repo_histories_on_board_id", using: :btree
  add_index "repo_histories", ["collected_on", "board_id"], name: "index_repo_histories_on_collected_on_and_board_id", unique: true, using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "board_id"
    t.datetime "date_to"
    t.decimal  "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subscriptions", ["board_id"], name: "index_subscriptions_on_board_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",           null: false
    t.string   "github_username", null: false
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "utm"
  end

  add_foreign_key "activities", "boards", on_delete: :cascade
  add_foreign_key "activities", "issue_stats", on_delete: :cascade
  add_foreign_key "activities", "users", on_delete: :cascade
  add_foreign_key "lifetimes", "columns"
  add_foreign_key "lifetimes", "issue_stats"
  add_foreign_key "subscriptions", "users"
end
