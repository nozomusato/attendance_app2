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

ActiveRecord::Schema.define(version: 20191116104101) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "overwork_finish"
    t.string "overwork_note"
    t.string "overwork_superior"
    t.string "next_day"
    t.string "work_request_permit"
    t.string "edit_request_permit"
    t.integer "conf_change"
    t.datetime "origin_start"
    t.datetime "origin_fin"
    t.boolean "nextday", default: false
    t.date "permitdate"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "basepoints", force: :cascade do |t|
    t.string "name"
    t.integer "number"
    t.string "attendtype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthrequests", force: :cascade do |t|
    t.date "req_date"
    t.string "month_approval"
    t.integer "boss_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_monthrequests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "employee_number"
    t.integer "uid"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2019-02-19 23:00:00"
    t.datetime "designated_work_start_time", default: "2019-02-19 23:00:00"
    t.boolean "superior", default: false
    t.datetime "designated_work_end_time", default: "2019-11-06 08:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
