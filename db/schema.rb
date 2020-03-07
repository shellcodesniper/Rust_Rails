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

ActiveRecord::Schema.define(version: 2020_02_21_085643) do

  create_table "broadcasts", force: :cascade do |t|
    t.string "title"
    t.string "content"
    t.integer "duration"
    t.datetime "next"
    t.integer "server_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_broadcasts_on_server_id"
  end

  create_table "combat_logs", force: :cascade do |t|
    t.integer "player_id"
    t.string "weapon"
    t.string "distance"
    t.string "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "damage"
    t.integer "attacker_id"
    t.integer "server_id"
    t.index ["attacker_id"], name: "index_combat_logs_on_attacker_id"
    t.index ["player_id"], name: "index_combat_logs_on_player_id"
    t.index ["server_id"], name: "index_combat_logs_on_server_id"
  end

  create_table "crons", force: :cascade do |t|
    t.string "job"
    t.datetime "next"
    t.integer "duration"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jails", force: :cascade do |t|
    t.string "server"
    t.string "jailtype"
    t.string "title"
    t.string "reason"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "judger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "player_id"
    t.boolean "executed"
    t.index ["player_id"], name: "index_jails_on_player_id"
  end

  create_table "messagelogs", force: :cascade do |t|
    t.datetime "time"
    t.integer "player_id"
    t.text "message"
    t.integer "server_id"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_messagelogs_on_player_id"
    t.index ["server_id"], name: "index_messagelogs_on_server_id"
  end

  create_table "notices", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.boolean "deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "modified_at"
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "steamid"
    t.boolean "vacban"
    t.boolean "gameban"
    t.boolean "familyshare"
    t.integer "steamplaytime"
    t.integer "serverplaytime"
    t.integer "seasonplaytime"
    t.string "connectip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "server_id"
    t.index ["server_id"], name: "index_players_on_server_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "title"
    t.string "reason"
    t.text "content"
    t.integer "server_id"
    t.integer "player_id"
    t.integer "user_id"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_reports_on_player_id"
    t.index ["server_id"], name: "index_reports_on_server_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "title"
    t.string "rcon_host"
    t.integer "rcon_port"
    t.string "rcon_pass"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "world_reset_type"
    t.string "map_reset_type"
    t.datetime "start_date"
    t.integer "world_reset_count"
    t.integer "map_reset_count"
    t.text "world_reset_command"
    t.text "map_reset_command"
    t.text "world_reset_notice_message"
    t.text "map_reset_notice_message"
    t.integer "current_reset_type"
  end

  create_table "updates", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.boolean "deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "modified_at"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "username", default: "", null: false
    t.string "realname", default: "", null: false
    t.string "steamid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
